<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#changeremark"
        style="height: 30px;">修改备注</button>
<div>
    <p style="font-size:24px;line-height: 34px;"><i class="fas fa-info"></i> DNS服务信息</p>
</div>

<p style="font-size:20px">当前授权的ip地址:{if !$user['ips']}
        还未授权ip地址
    {else}
        {$user['ips']}
    {/if}<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#changeip" style="height: 30px;"
        onclick="edit_ips()"><i class="fas fa-edit"></i> 修改</button></p>
<p style="font-size:20px">DNS地区:{if !$user['ips']}
        未选择
    {else}
        {$node_info['name']}
    {/if}<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#aerachange"
        style="height: 30px;" onclick="edit_aera()"><i class="fas fa-edit"></i> 修改</button></p>
<p style="font-size:20px">接入信息:</p>
{if $node_info['dns']}
<div class="row" id="dns_row">
    <div class="col-xs-12 col-sm-6">
        <p style="font-size:18px">DNS: <a class="ccp" id="dns">{$node_info['dns']}</a></p>
        <p style="font-size:18px">DNSv6: <a class="dnsv6 ccp">{$node_info['dnsv6']}</a></p>
    </div>
    <div class="col-xs-12 col-sm-6">
        <p style="font-size:18px">DoH: <a class="doh ccp">{$node_info['doh']}</a></p>
        <p style="font-size:18px">DoT: <a class="doh ccp">{$node_info['dot']}</a></p>
    </div>
</div>
{else}
<div>
{base64_decode($node_info['ss'])}
</div>
{/if}
<button type="button" class="btn btn-primary" data-toggle="modal" onclick="window.open('https://docs.streamdns.fun/', '_blank');"
            style="height: 30px;"><i class="fas fa-question"></i> 接入指南</button>
            <hr/>
<div class="col-xs-12">
            <p style="font-size:18px;line-height: 28px;"><i class="fas fa-fw fa-traffic-light"></i> 流量用量</p>
            <div>
                <span class="monthly_traffic_usage">{$traffic}</span>
                <span> / </span>
                <span class="monthly_traffic_limit">∞</span>
                <span style="float: right"><span class="monthly_traffic_percent">流量用量: 0</span> %</span>
            </div>
            <div class="progress" style="margin-bottom: 24px;">
                <div class="progress-bar progress-bar-striped progress-bar-info active monthly_traffic_percent_bar" role="progressbar" aria-valuenow="45" aria-valuemin="0" aria-valuemax="100" style="width: 100%;">
                </div>
            </div>
        </div>
<!-- Modal -->
<div class="modal fade" id="aerachange" tabindex="-1" role="dialog" aria-labelledby="aerachangeLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                        aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="aerachangeLabel">修改接入地区</h4>
            </div>
            <div class="modal-body" id="aera_body">
            <p style="color:red;">注意:您绑定的所有ip只能使用同一个地区,如有需求请联系客服拆分套餐.最低2ip/套餐</p>
                <select id="aera_select" class="form-control"></select>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="aera_submit">提交</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="changeip" tabindex="-1" role="dialog" aria-labelledby="changeipLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                        aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="changeipLabel">修改授权ip</h4>
            </div>
            <div class="modal-body" id="ips_body">
                <p>为防止滥用,修改后30分钟将无法再次修改!!</p>
                <div class="form_group">
                    <div id="form_group">
                        <div class="mb-1">
                            <div class="input-group"><input name="ips_0" placeholder="输入IP" type="text"
                                    class="form-control" value="">
                            </div>

                        </div>
                    </div>
                    <button type="button" class="btn btn-link btn-block btn-sm" title="添加标识符" id="add-ips"
                        style="font-size:large;padding-right:2.75px;">
                        <i class="fas fa-plus" style="color:black;"></i>
                    </button>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="ips_submit">提交</button>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="changeremark" tabindex="-1" role="dialog" aria-labelledby="changeremarkLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                        aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="changeipLabel">修改备注</h4>
            </div>
            <div class="modal-body" id="changeremark_body">
                <div class="form_group">
                    <div>
                        <div class="mb-1">
                            <div class="input-group"><input placeholder="输入新备注" type="text"
                                    class="form-control" value="" id="changeremark_input">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="changeremark_submit">提交</button>
            </div>
        </div>
    </div>
</div>
{* <script>
if(!$("#dns").text() && {$user['node']}){
    $("#dns_row").removeClass("row");
    $("#dns_row").html("{$node_info['ss']}");
}
</script> *}
<script>
    $("#changeremark_submit").click(function(){
        if($("#changeremark_input").val()==""){
            $("#changeremark_input").val("NULL");
        }
        $('<p id="changeremark_submitd">提交中...</p>').appendTo($("#changeremark_body"));
        $("#changeremark_submit").attr("disabled", "true");
        //ajax
        $.ajax({
            type: "GET",
            url: "clientarea.php?action=productdetails&id={$serviceid}&ajax=update_remark&remark="+$("#changeremark_input").val(),
            success:function(result){
                result=JSON.parse(result);
                if(result['ok']==1){
                    $("#changeremark_submitd").text("提交成功,正在跳转");
                    window.location.reload();
                }else{
                    $("#changeremark_submitd").text("提交失败,"+result['msg']+",请重试");
                    $("#changeremark_submit").removeAttr("disabled");
                }
            
            },
            error:function(){
                $("#changeremark_submitd").text("提交错误,请刷新后重新提交!");
            }
        });
    })
</script>
<script>
function copy(text) {
    var x = document.createElement("textarea");
    x.textContent = text;
    document.body.appendChild(x);
    x.select();
    document.execCommand('copy');
    x.remove();
}
    document.querySelectorAll(".ccp").forEach(x=>{
        x.onclick = (x)=>{
            copy(x.target.innerText);
        }
        x.setAttribute("data-toggle", "tooltip");
        x.setAttribute("title", "单击复制");
    }
    );

</script>
<script>
    function edit_aera(){
        let aeras={json_encode($aeras)};
        //init.
        let aera_list={};
        for (i in aeras){
            if(!aera_list[aeras[i]['aera']]){
                aera_list[aeras[i]['aera']]=[];
                aera_list[aeras[i]['aera']].push(aeras[i]);
            }else{
                aera_list[aeras[i]['aera']].push(aeras[i]);
            }
            //console.log(aera_list);
        }
        //generate
        let html="";
        for (i in aera_list){
            html+='<optgroup label="'+i+'">'
            for (j in aera_list[i]){
                nodeaaaaa=aera_list[i][j]['id'];
                if(nodeaaaaa=={$user['node']}){
                    html+='<option value="'+nodeaaaaa+'" selected>'+aera_list[i][j]['name']+'('+aera_list[i][j]['info']+')</option>'
                }else{
                    html+='<option value="'+nodeaaaaa+'">'+aera_list[i][j]['name']+'('+aera_list[i][j]['info']+')</option>'
                }
                console.log(j);
            }
            html+='</optgroup>';
        }
        $("#aera_select").html(html);
    }
    $("#aera_submit").click(function(){
        $('<p id="aera_submitd">提交中...</p>').appendTo($("#aera_body"));
        $("#aera_submit").attr("disabled", "true");
        //ajax
        $.ajax({
            type: "POST",
            url: "clientarea.php?action=productdetails&id={$serviceid}&ajax=update_aera",
            data: { node_id:$("#aera_select").val() },
            success:function(result){
                result=JSON.parse(result);
                if(result['ok']==1){
                    $("#aera_submitd").text("提交成功,正在跳转");
                    window.location.reload();
                }else{
                    $("#aera_submitd").text("提交失败,"+result['msg']+",请重试");
                    $("#aera_submit").removeAttr("disabled");
                }
            
            },
            error:function(){
                $("#aera_submitd").text("提交错误,请刷新后重新提交!");
            }
        });
    })
</script>
<script>
    function edit_ips() {
        let updated_date=new Date({$user['updated_at']}*1000);
        let now_date=new Date();
        if((now_date-updated_date)<=1800000){
            $("#ips_body").html("出于滥用限制,您还需等待"+(1800000-(now_date-updated_date))+"ms后才能再次修改");
            $("#ips_submit").attr("disabled", "true");
            return;
        }
        let ips={json_encode($ips)};
        if (ips.length <= 0)
            return 0;
        let html =
            '<div class="mb-1"><div class="input-group"><input name="ips_0" placeholder="输入IP" type="text" class="form-control" value="' +ips[0] + '"></div></div>'
        for (let i = 1; i < ips.length; i++) {
            html +='<div class="mb-1"><div class="input-group"><input name="ips_x" placeholder="输入IP" type="text" class="form-control" value="'+ips[i]+'"><span class="input-group-append"><button type="button" class="btn btn-secondary" style="font-size:large;padding-right:2.75px;"><i class="far fa-times"></i></button></span></div></div>'
        }
        $("#form_group").html(html);
        reips();
    }
    $("#add-ips").click(function() {
        ip_limit={$user["ip_limit"]};
        if ($("#form_group").children().length >= ip_limit) {
            alert("您最多能添加 " + ip_limit + " 个ip");
            return 1;
        };

        $('<div class="mb-1"><div class="input-group"><input name="ips_x" placeholder="输入IP" type="text" class="form-control" value=""><span class="input-group-append"><button type="button" class="btn btn-secondary" style="font-size:large;padding-right:2.75px;"><i class="far fa-times"></i></button></span></div></div>')
            .appendTo($("#form_group"))
        reips();
    });

    function reips() {
        var i = 0;
        $("#form_group>div").each(function() {
            $(this).children("div").children("input").attr("name", "ips_" + i);
            if (i != 0)
                $(this).children("div").children("span").children("button").attr('onclick', 'del_ip(' + i +
                    ')');
            i += 1;
        })
    }

    function del_ip($ipi) {
        $("#form_group").children().eq($ipi).remove();
        reips();
    }

    $("#ips_submit").click(function(){
        $('<p id="submitd">提交中...</p>').appendTo($("#ips_body"));
        $("#ips_submit").attr("disabled", "true");
        let ips =[];
        let flag=0;
        {literal}
        ip_rgx=RegExp("^(((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))\\.){3}((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))$")
        {/literal}
        cidr_rgx=/((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)(25[0-5]|2[0-4]\d|[01]?\d\d?)(?:(\/([1-9]|[1-2]\d|3[0-1])))/i
        $("#form_group>div").each(function() {
            let val=$(this).children("div").children("input").val();
            if(val==""){
                alert("不能为空");
                flag=1;
            }
            else if (!ip_rgx.test(val)){
                alert("ip不合法,特别注意是否存在空格");
                flag=1;
            }
            else if(cidr_rgx.test(val)){
                alert("CIDR格式暂不支持");
                flag=1;
            }
            else{
                ips.push(val);
            }
        
        })
        if(flag){
            $("#submitd").remove();
            $("#ips_submit").removeAttr("disabled");
        }else{
            //ajax
            $.ajax({
                type: "POST",
                url: "clientarea.php?action=productdetails&id={$serviceid}&ajax=update_ips",
                data: { ips:ips },
                success:function(result){
                    result=JSON.parse(result);
                    if(result['ok']==1){
                        $("#submitd").text("提交成功,正在跳转");
                        window.location.reload();
                    }else{
                        $("#submitd").text("提交失败,"+result['msg']+",请重试");
                    }
                
                },
                error:function(){
                    $("#submitd").text("提交错误,请刷新后重新提交!");
                }
            });
            
        }
    })
</script>
