# 停止并删除原有容器，记得备份！
docker stop iptv
docker rm iptv
# 拉取最新的镜像并上线
docker-compose pull youshandefeiyang/allinone:latest
docker-compose up -d
