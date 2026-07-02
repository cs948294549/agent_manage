# monitor_agents
每个agent需要control脚本实现 control start/stop/status

## agent约定

- 必须提供control脚本
- `./control start`可以启动agent
- `./control stop`可以停止agent
- `./control status`打印出状态信息，只能是started或者stoped
- control文件已经有可执行权限，并且在tarball根目录下


### 打包
```
tar -czf <agent-name>-<version>.tar.gz *

md5sum <agent-name>-<version>.tar.gz > <agent-name>-<version>.tar.gz.md5
```
