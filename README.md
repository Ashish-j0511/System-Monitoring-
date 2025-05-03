# System-Monitoring-DashBoard
This Bash script provides a real-time system monitoring dashboard in the terminal. It displays essential system metrics like CPU and memory usage, disk space, top processes, and network statistics in a formatted output. 

## 📋 Features

- **CPU Usage**: Graphical bar + load averages.
- **Memory Usage**: RAM and swap usage.
- **Disk Usage**: Disk space with usage warnings.
- **Top Processes**: By CPU and memory.
- **Network Monitoring**: Active connections, packet drops, I/O stats.
- **Service Monitoring**: Status of `sshd`, `nginx`, `httpb`, `iptables`.
- **Custom Views**: Use CLI switches to display specific modules.

---

## 🛠️ Requirements

- VirtualBox with Ubuntu/Oracle OS installed.
- Bash shell environment.

 **Clone the repository**:
```
git clone https://github.com/Ashish-j0511/System-Monitoring-Dashboard.git
cd System-Monitoring-Dashboard
```


** Make the script executable **
```
chmod +x Monitorind_System_Dashboard.sh 
```
## 🧪 Usage Examples :
** Run the script:**
```
./Monitorind_System_Dashboard.sh
```

** Run the script with the desired switch: **
```
./Monitorind_System_Dashboard.sh -cpu
./Monitorind_System_Dashboard.sh -memory ```
```

