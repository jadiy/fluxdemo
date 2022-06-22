#!/bin/sh

# 使用说明，用来提示输入参数
usage() {
	echo "Usage: sh 执行脚本.sh [port|base|app|stop|rm]"
	exit 1
}

# 开启所需端口
port(){
	firewall-cmd --add-port=80/tcp --permanent
	firewall-cmd --add-port=8080/tcp --permanent
	firewall-cmd --add-port=8848/tcp --permanent
	firewall-cmd --add-port=9848/tcp --permanent
	firewall-cmd --add-port=9849/tcp --permanent
	firewall-cmd --add-port=6379/tcp --permanent
	firewall-cmd --add-port=3306/tcp --permanent
	firewall-cmd --add-port=9100/tcp --permanent
	firewall-cmd --add-port=9200/tcp --permanent
	firewall-cmd --add-port=9201/tcp --permanent
	firewall-cmd --add-port=9202/tcp --permanent
	firewall-cmd --add-port=9203/tcp --permanent
	firewall-cmd --add-port=9300/tcp --permanent
	service firewalld restart
}

# 构建基础镜像（必须）
init(){
	cd ../../ && DOCKER_BUILDKIT=1 docker build -t ruoyi-init -f buildkitDockerfile . && \
	cd code/ruoyi-ui && DOCKER_BUILDKIT=1 docker build -t docker_ruoyi-ui -f buildkitDockerfile .
}
# 启动基础环境（必须）
base(){
	docker-compose up -d ruoyi-mysql ruoyi-redis ruoyi-nacos
}

# 启动程序模块（必须）
app(){
	docker-compose up -d ruoyi-nginx ruoyi-gateway ruoyi-auth ruoyi-modules-system
}

# 关闭所有环境/模块
stop(){
	docker-compose stop
}

# 删除所有环境/模块
rm(){
	docker-compose rm
}

# push
push(){
	docker-compose rm
}

# 根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"port")
	port
;;
"init")
	init
;;
"base")
	base
;;
"app")
	app
;;
"stop")
	stop
;;
"rm")
	rm
;;
*)
	usage
;;
esac
