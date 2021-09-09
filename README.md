# SecureSSH 介绍
保护SSH端口不受侵害，免受来自网络不断刺探SSH密码带来的安全风险。<br>
目前提供借助ufw、阿里云ECS安全组的拦截脚本。<br>
<br>
发现恶意IP默认阻断一周的所有端口访问，一周后释放。请根据实际环境选择对应脚本。<br>
若使用阿里云ECS服务器，推荐使用阿里云安全组拦截脚本。<br>
<br>
## 阿里云ECS安全组<br>
**系统中需要先部署阿里云CLI，具体部署方法参考：https://help.aliyun.com/document_detail/121541.html**<br>
<br>
并且修改脚本中如下字段<br>
strRegionId=cn-hangzhou<br>
strSecurityGroupId=sg-bp171vm9829r********<br>
## 定时运行<br>
crontab -e
