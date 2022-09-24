from re import L
from tabnanny import check
import flask
import flask_restful
from flask_restful import reqparse
import ipset
import stream
app = flask.Flask(__name__)
api = flask_restful.Api(app)
token = "ZUxgeTeFeSsAUWoscpIqsRfPlWvhSZUPeCpWKqyzdbQasgFlLP"
post_parser = reqparse.RequestParser()
post_parser.add_argument('old_ips', type=str, required=False)
post_parser.add_argument('new_ips', type=str, required=False)


class Fetch(flask_restful.Resource):
    def get(self):
        # ips.fetch()[0].get_attr('IPSET_ATTR_ADT').get_attrs('IPSET_ATTR_DATA')[0].get_attr('IPSET_ATTR_IP_FROM').get_attr('IPSET_ATTR_IPADDR_IPV4')
        # ips.fetch()[0].get_attr('IPSET_ATTR_ADT').get_attrs('IPSET_ATTR_DATA')[0].get_attr('IPSET_ATTR_BYTES')
        return ips.fetch()


class Update(flask_restful.Resource):
    def post(self):
        fe = ips.fetch()
        args = post_parser.parse_args()
        ips.del_ips(eval(args['old_ips']))
        ips.add_ips(eval(args['new_ips']))
        return fe


class StreamFetch(flask_restful.Resource):
    def get(self):
        return {'ipv4': stream.nf(ip='4'), 'ipv6': stream.nf(ip='6')}


api.add_resource(Fetch, '/'+token+'/fetch')
api.add_resource(Update, '/'+token+'/update')
api.add_resource(StreamFetch, '/public/streamfetch')
if __name__ == '__main__':
    ips = ipset.backend()
    app.run(debug=True, port=22300, host="0.0.0.0")
