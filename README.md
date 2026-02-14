# Hyper-GPU-PV 
Hyper simple, hyper reliable 

## Requirements 🚀
- **Hyper-V fully installed**  
  (see official requirements here: [Microsoft Hyper-V Requirements](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v))
- **Partitionable GPU**   
  *(check with `Get-VMHostPartitionableGpu`)*
- **Graphics card with up-to-date drivers** 

---

### Instructions 🧠

1. **Create a VM**   
   - If not done already, create a VM with your preferred OS, CPU, RAM, and disk.  
   - *Optional:* perform an unattended installation if your XML is wrapped into an ISO.

2. **Add a virtual GPU to the VM** 
   From here, you have **two options**:

<details>
<summary>Option 1: Automated Driver Store Transfer </summary>

- The driver store files are copied automatically to the VM when the virtual GPU adapter starts.  
- **Host PC steps:**  
  1. Download and run `DriverStoreCopyMode.reg`, then reboot the VM.  
  2. Download and open `HyperGPU.ps1` in **Windows PowerShell ISE**.  
  3. Edit the **mandatory section** in the script to match your VM configuration.  
- Start your VM—the driver store transfer happens automatically.

</details>

<details>
<summary>Option 2: Manual Driver Store Transfer </summary>

- Full manual control over GPU driver installation.  
- **Host PC steps:**  
  1. Download and open `HyperGPU.ps1` in **Windows PowerShell ISE**.  
  2. Edit both the **mandatory** and **manual installation sections** in the script.  
- *Note:* You must repeat this process every time you update GPU drivers on the host.

</details>
