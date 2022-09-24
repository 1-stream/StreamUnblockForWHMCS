{* <a href="#" id="loginadg">登陆到AdGuardHome</a>
<hr/> *}
<p style="font-size:18px;margin-bottom: 0px;">允许的客户端</p>
<span class="text-lighter">CIDR、IP 地址或客户端 ID 的列表。如已配置，则 AdGuard Home 将仅接受来自这些客户端的请求。</span>
<textarea class="form-control" rows="6" id='ips'></textarea>
<hr/>
<button type="button" class="btn btn-primary" id="ips_submit">提交修改</button>
<hr/>
<p style="font-size:20px">接入信息:</p>
<div class="row">
    <div class="col-xs-12 col-sm-6">
        <p style="font-size:18px">DNS: <a class="dns ccp">{$node_info['dns']}</a></p>
        <p style="font-size:18px">DNSv6: <a class="dnsv6 ccp">{$node_info['dnsv6']}</a></p>
    </div>
    <div class="col-xs-12 col-sm-6">
        <p style="font-size:18px">DoH: <a class="doh ccp">{$node_info['doh']}</a></p>
        <p style="font-size:18px">DoT: <a class="doh ccp">{$node_info['dot']}</a></p>
    </div>

</div>
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
window.onload=function(){
    let ips={json_encode($ips)};
    ipstext = ips.join("\n");
    $("#ips").val(ipstext);
};
$("#ips_submit").click(function(){
    let ips=$('#ips').val().split('\n');
    console.log(ips);
    ip_rgx=/((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)(25[0-5]|2[0-4]\d|[01]?\d\d?)/i
    cidr_rgx=/((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)((25[0-5]|2[0-4]\d|[01]?\d\d?)\.)(25[0-5]|2[0-4]\d|[01]?\d\d?)(?:(\/([1-9]|[1-2]\d|3[0-1])))/i
    ips.forEach(function(ip){
        if(ip==""){
            alert("不能为空");
            return;
        }
        else if (!ip_rgx.test(ip)){
            alert("ip不合法");
            return;
        }
        else if(cidr_rgx.test(ip)){
            alert("CIDR格式暂不支持");
            return;
        }
    });
    $.ajax({
        type: "POST",
        url: "clientarea.php?action=productdetails&id={$serviceid}&ajax=update_ips",
        data: { ips:ips },
        success:function(result){
            result=JSON.parse(result);
            if(result['ok']==1){
                alert("提交成功");
                {* window.location.reload(); *}
            }else{
                alert("提交失败,"+result['msg']+",请重试");
            }
        
        },
        error:function(){
            alert("提交错误,请刷新后重新提交!");
        }
    });
});
</script>