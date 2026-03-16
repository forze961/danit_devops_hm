## Bash scripts

| Exercise                                   | Description                                            | Source Code                  | Execution Result               |
|:-------------------------------------------|:-------------------------------------------------------|:-----------------------------|:-------------------------------|
| **1: Random number generator and gueeser** | *run with --debug if you want to show radom num before | [guess.sh](scripts/guess.sh) | ![Guess res](assets/guess.png) |

## SSH
### I a little bit changed exercises, but main impact stay same 
| Exercise                                                                  | Source Code                                                                 | Execution Result                         |
|:--------------------------------------------------------------------------|:----------------------------------------------------------------------------|:-----------------------------------------|
| **1: Allow to use rsa keys for ssh connect for specific user**            | -                                                                           | ![res](assets/ssh_allowed_by_key.png)    |
| **2: Start separate ssh server on debug mode only for john at 3333 port** | -                                                                           | ![res](assets/ssh_on_3333_debug.png)     |
| **2.1: Check that another users is not allowed**                          | -                                                                           | ![res](assets/ssh_for_another_users.png) |
| **3: Start separate ssh server as a service and check status for both**   | [service](configs/ssh-debug.service), [sshd cfg](configs/sshd_config_debug) | ![res](assets/ssh_servers_statuses.png)  |
