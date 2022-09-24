<button type="button" class="btn btn-primary" data-toggle="modal" data-target="#changeremark"
        style="height: 30px;">修改备注</button>
<hr/>
<p style="font-size:20px">当前授权的ip地址:<span id="ips_cur">{if !$user['ips']}还未授权ip地址{else}{$user['ips']}{/if}</span><button type="button" class="btn btn-primary" style="height: 30px;" onclick="edit_ips()" id="edit_ips_button"><i class="fas fa-edit"></i> 修改</button></p>
<div id="ips_form" hidden>
    <textarea class="form-control" rows="6" id='ips'></textarea>
    <hr/>
    <button type="button" class="btn btn-primary" id="ips_submit" style="height: 30px;" >提交修改</button>
</div>
<hr/>
<p style="font-size:20px">DNS节点:<span id="node_cur"></span><button type="button" class="btn btn-primary" style="height: 30px;" onclick="edit_node()" id="edit_node_button"><i class="fas fa-edit" ></i> 修改</button></p>
<div id="node_form" hidden>
    <label for="id_select"> DNS接入区域 <select id="node_server" class="form-control"></select></label>
    <span style="font-size:20px">-</span>
    <label for="id_select"> DNS解锁区域 <select id="node_area" class="form-control"></select></label>
    <hr/>
    <button type="button" class="btn btn-primary" id="node_submit" style="height: 30px;" >提交修改</button>
</div>
<div class="row" id="dns_row">
    <div class="col-xs-12 col-sm-6">
        <p style="font-size:18px">DNS: <a class="ccp" id="dns"></a></p>
        {* <p style="font-size:18px">DNSv6: <a class="dnsv6 ccp">{$node_info['dnsv6']}</a></p> *}
    </div>
    <div class="col-xs-12 col-sm-6">
        <p style="font-size:18px">DoH: <a class="ccp" id="doh"></a></p>
        {* <p style="font-size:18px">DoT: <a class="doh ccp">{$node_info['dot']}</a></p> *}
    </div>
</div>
<button type="button" class="btn btn-primary" data-toggle="modal" onclick="window.open('https://docs.streamdns.fun/', '_blank');"
            style="height: 30px;"><i class="fas fa-question"></i> 接入指南(文档)</button>
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
let dns_array={json_encode($nodes['dns'])};
let servers_array={json_encode($nodes['servers'])};
let servers={};
let dns={};
servers_array.forEach(function(item,index){
    servers[item['id']]=item;
});
dns_array.forEach(function(item,index){
    dns[item['id']]=item;
});
nodesineachserver={};
dns_array.forEach(function(item,index){
    if(!nodesineachserver[item['server_id']]){
        nodesineachserver[item['server_id']]=[];
        nodesineachserver[item['server_id']].push(item);
    }else{
        nodesineachserver[item['server_id']].push(item);
    }
});
if(!{$user['node']}){
    $("#node_cur").text("未选择,→");
}
else{
$("#node_cur").text(servers[dns[{$user["node"]}]['server_id']]['remark']+"-"+dns[{$user["node"]}]['remark']);
$("#dns").text(servers[dns[{$user['node']}]['server_id']]['dns']);
$("#doh").text(servers[dns[{$user['node']}]['server_id']]['doh']);
}
</script>
<script>
function edit_ips(){
    let ips={json_encode($ips)};
    ipstext = ips.join("\n");
    $("#ips").val(ipstext);
    $("#ips_form").removeAttr("hidden");
    $("#edit_ips_button").prop("hidden", "hidden");
    $("#ips_cur").prop("hidden", "hidden");
}
$("#ips_submit").click(function(){
    let ips=$('#ips').val().split('\n');
    console.log(ips);
    {literal}
        ip_rgx=RegExp("^(((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))\\.){3}((\\d{1,2})|(1\\d{2})|(2[0-4]\\d)|(25[0-5]))$")
        domain_rgx=RegExp("^((?!-)[A-Za-z0-9-]{1,63}(?<!-)\\.)+[A-Za-z]{2,6}$")
    {/literal}
    cidr_rgx=/((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)(25[0-5]|2[0-4]\d|[01]?\d\d?)(?:(\/([1-9]|[1-2]\d|3[0-1])))/i
    flag=0;
    ips.forEach(function(ip){
        if(ip==""){
            alert("ip不能为空");
            flag=1;
        }
        else if (!ip_rgx.test(ip)&!domain_rgx.test(ip)){
            alert("ip或域名不合法");
            flag=1;
        }
        else if(cidr_rgx.test(ip)){
            alert("CIDR格式暂不支持");
            flag=1;
        }
    });
    if(flag){
        return;
    }
    $('<p id="ips_submitd">提交中...</p>').appendTo($("#ips_form"));
    $("#ips_submit").attr("disabled", "true");
    $.ajax({
        type: "POST",
        url: "clientarea.php?action=productdetails&id={$serviceid}&ajax=update_ips",
        data: { ips:ips },
        success:function(result){
            result=JSON.parse(result);
            if(result['ok']==1){
                $("#ips_submitd").text("提交成功,正在跳转");
                window.location.reload();
            }else{
                $("#ips_submitd").text("提交失败,"+result['msg']+",请重试");
                $("#ips_submit").removeAttr("disabled");
            }
        
        },
        error:function(){
            $("#ips_submitd").text("提交错误,请刷新后重新提交!");
        }
    });
});
</script>
<script>
function edit_node(){
    html_opt_1=""
    node_cur_id={$user['node']}?{$user['node']}:1;
    for(server in servers){
        console.log(server);
        if(dns[node_cur_id]['server_id']==server){
            html_opt_1+='<option value="'+servers[server]['id']+'" selected>'+servers[server]['remark']+'</option>'
        }else{
            html_opt_1+='<option value="'+servers[server]['id']+'">'+servers[server]['remark']+'</option>'
        }
    };
    $("#node_server").html(html_opt_1);
    html_opt_2=""
    nodes=nodesineachserver[dns[node_cur_id]['server_id']];
    for(node in nodes){
        console.log(nodes[node]);
        if(node_cur_id==nodes[node]['id']){
            html_opt_2+='<option value="'+nodes[node]['id']+'" selected>'+nodes[node]['remark']+'</option>'
        }else{
            html_opt_2+='<option value="'+nodes[node]['id']+'">'+nodes[node]['remark']+'</option>'
        }
    };
    $("#node_area").html(html_opt_2);
    $("#node_form").removeAttr("hidden");
    $("#edit_node_button").prop("hidden", "hidden");
    $("#node_cur").prop("hidden", "hidden");
}
$("#node_server").change(function(){
    node_id=$("#node_server").val();
    console.log()
    html_opt_3=""
    nodes=nodesineachserver[node_id];
    for(node in nodes){
        console.log(nodes[node]);
            html_opt_3+='<option value="'+nodes[node]['id']+'">'+nodes[node]['remark']+'</option>'
    };
    $("#node_area").html(html_opt_3);
});
$("#node_submit").click(function(){
        $('<p id="node_submitd">提交中...</p>').appendTo($("#node_form"));
        $("#node_submit").attr("disabled", "true");
        //ajax
        $.ajax({
            type: "POST",
            url: "clientarea.php?action=productdetails&id={$serviceid}&ajax=update_aera",
            data: { node_id:$("#node_area").val() },
            success:function(result){
                result=JSON.parse(result);
                if(result['ok']==1){
                    $("#node_submitd").text("提交成功,正在跳转");
                    window.location.reload();
                }else{
                    $("#node_submitd").text("提交失败,"+result['msg']+",请重试");
                    $("#node_submit").removeAttr("disabled");
                }
            
            },
            error:function(){
                $("#node_submitd").text("提交错误,请刷新后重新提交!");
            }
        });
    })
</script>