# Questions to Study for the Midterm Test

These questions come from the end of labs and posted lectures. The Midterm will have forty (40) of these questions on it. The Midterm is sixty (60) minutes long. They are all multiple choice. The Midterm is during your theory class week 7, in our regular class. Check labs and lectures to know what questions belong to each.

1. What do the initials GUI stand for?
   A. General User Interaction
   B. Global Unique Identifier
   C. Graphical User Interface
   D. Graphical Unified Input

2. What does NAT stand for?
   A. Network Access Technology
   B. Node Address Table
   C. Network Allocation Transfer
   D. Network Address Translation

3. What is a host only virtual network?
   A. A network that allows communication only between the host and its virtual machines
   B. A virtual network that connects VMs directly to the external physical network
   C. A network that translates host IPs to external addresses
   D. A network that isolates VMs completely from the host and other networks

4. What is a bridged virtual network?
   A. A virtual network that uses NAT to share the host's IP address
   B. A network isolated from both host and external networks
   C. A network exclusively for container communication
   D. A virtual network that uses the host's adapter to connect VMs directly to the physical LAN

5. Why is Auto bridging not recommended?
   A. It can cause IP conflicts and unpredictable routing
   B. It improves performance at the cost of security
   C. It is only available on legacy hardware
   D. It requires manual configuration of each VM's network

6. What is ESXI?
   A. A desktop virtualization client
   B. A bare-metal hypervisor from VMware
   C. A file system used by VMware
   D. A management console for virtual networks

7. What is Fusion?
   A. A command-line network utility in VMware
   B. VMware's server hypervisor for Windows
   C. VMware's desktop virtualization product for macOS
   D. A tool for merging virtual disks

8. What is the difference between UEFI and BIOS?
   A. UEFI supports GPT, secure boot and modern interface; BIOS uses MBR and legacy interface
   B. BIOS supports secure boot; UEFI does not
   C. UEFI is only used on servers; BIOS only on desktops
   D. They are identical in functionality

9. What is SAS?
   A. Storage Area Switch protocol
   B. Secure Authentication Service
   C. Serial Attached SCSI, a point-to-point storage interface
   D. Service Application Suite

10. What is the difference between IDE, SCSI, SATA, and NVMe?
   A. They are virtualization network protocols
   B. They are CPU architectures
   C. They are file-system formats
   D. They are storage interfaces with increasing performance: IDE < SCSI < SATA < NVMe

11. Why should you allocate all disk space at the start?
   A. To improve snapshot performance
   B. To avoid disk fragmentation and improve performance
   C. To enable thin provisioning
   D. To reduce host CPU usage

12. Why did we choose Desktop Experience?
   A. It installs only core server roles
   B. It provides the full GUI and client-side tools
   C. It removes support for Server Core commands
   D. It automatically configures Active Directory

13. What are the advantages of Active Directory Integrated zones?
   A. Zones are stored only on the primary server
   B. Zone data replicates automatically with AD replication
   C. You must manually export zone files for backups
   D. They require no DNS service to be installed

14. What does installing VMware tools do?
   A. Converts the VM to a template
   B. Adds paravirtualized drivers and improves performance
   C. Disables snapshot functionality
   D. Forces the VM to use BIOS boot only

15. How do you open your network interfaces by text command?
   A. ncpa.cpl
   B. ipconfig /all
   C. netsh interface show
   D. route print

16. What is the address 172.16.89.253 used for in the lab?
   A. Default gateway for the virtual network
   B. DNS forwarder on the external router
   C. IP for the domain controller's secondary NIC
   D. DHCP server address

17. When we are setting up our 172.16.0.0 network, do we use NAT or Bridged?
   A. NAT
   B. Host-only
   C. Bridged
   D. Internal

18. What is the address 8.8.8.8?
   A. Google's public DNS server
   B. Microsoft time server
   C. Cloudflare's DNS server
   D. Cisco's NTP server

19. Is DNS Server a Role or a Feature?
   A. Role
   B. Feature
   C. Both
   D. Neither

20. What is the zone name of your Primary forward lookup zone? Use ^^??? to represent your numbers.
   A. dm^^???.cst8342.com
   B. cst8342-^^???.local
   C. lab^^???.internal
   D. ^^???.domain.com

21. What extension is given to a forward lookup zone file?
   A. .fwd
   B. .dns
   C. .zone
   D. .txt

22. What would be the name of your revers lookup zone file?
   A. reverse.dns
   B. 0.16.172.in-addr.arpa.dns
   C. ptr-zone.dns
   D. arpa.zone

23. When creating forwarders in our lab DNS server, what IP4 address must come first?
   A. 8.8.8.8
   B. 1.1.1.1
   C. 172.16.89.253
   D. 192.168.1.1

24. What Server Role must we add in Server MAnager to enable Active Directory?
   A. Active Directory Services
   B. Domain Services
   C. Active Directory Domain Services
   D. Directory Management

25. Why did we not create a DNS delegation when installing Active Directory?
   A. We are creating a new forest root domain
   B. DNS delegation is deprecated
   C. It would break DNS resolution
   D. We don't have DNS installed

26. What would be the default NetBIOS domain name for your domain? Assume ^^??? represents your numbers.
   A. DM^^???
   B. CST8342-^^???
   C. DOMAIN^^???
   D. LAB^^???

27. What type of objects are "ITS, HelpDesk, Development, and CustSupport" in ADUC?
   A. Users
   B. Computers
   C. Organizational Units (OUs)
   D. Security Groups

28. Under what existing policy were you told to modify, to allow users to login locally on the server? Default Domain Policy or Default Domain Controlers Policy.
   A. Default Domain Policy
   B. Default Domain Controllers Policy
   C. Local Security Policy
   D. Server Login Policy

29. Under what existing policy section were you told to modify, to allow users to login locally on the server? Computer Configuration or User Configuration.
   A. Computer Configuration
   B. User Configuration
   C. Security Configuration
   D. Local Policies

30. What is the policy name, that you have to open to allow a user to login locally on the server?
   A. Allow log on locally
   B. Remote Desktop Users
   C. Interactive Logon
   D. User Rights Assignment

31. What path do we need to open to get to the policy to allow users to login locally on the server?
   A. Computer Configuration > Policies > Windows Settings > Security Settings > Local Policies > User Rights Assignment
   B. User Configuration > Administrative Templates > System
   C. Computer Configuration > Administrative Templates > Network
   D. User Configuration > Policies > Security Settings

32. What is the difference between Assigned applications and Published Applications?
   A. Assigned apps auto-install; Published apps appear in Add/Remove Programs for optional install
   B. Published apps are mandatory; Assigned apps are optional
   C. Assigned apps are for users only; Published apps are for computers only
   D. There is no difference

33. What is a Source Starter GPO?
   A. A GPO used as a template with preconfigured settings
   B. The first GPO created in a domain
   C. A GPO that starts services automatically
   D. A temporary GPO for testing

34. What type of naming convention is "\\ServerName\ShareName"?
   A. URL path
   B. UNC (Universal Naming Convention) path
   C. DNS name
   D. NetBIOS path

35. What is the purpose of an MX record?
   A. Points to the mail server for a domain
   B. Maps hostnames to IP addresses
   C. Defines spam filter rules
   D. Authorizes email senders

36. What is the purpose of "ipconfig /flushdns"?
   A. Clears the DNS resolver cache
   B. Displays the current IP configuration
   C. Flushes the router's cache
   D. Updates DNS records on the server

37. What is "127.0.0.1"?
   A. The broadcast address
   B. The loopback (localhost) address
   C. A public DNS server address
   D. The default gateway address

38. What does "Install‐WindowsFeature" do?
   A. Installs Windows updates
   B. Installs Windows Roles and Features via PowerShell
   C. Installs third-party applications
   D. Creates new virtual machines

39. What does ".\Setup.exe /PrepareSchema" do?
   A. Prepares the Active Directory schema for Exchange
   B. Installs Windows Server
   C. Creates a new database schema
   D. Configures DNS zones

40. What is the difference between "x86" and "x64"?
   A. x86 is 32-bit; x64 is 64-bit architecture
   B. x86 is newer than x64
   C. x86 is for servers; x64 is for desktops
   D. They are the same

41. Why do we get a warning message when we first type "<https://mail.dm^^???.cst8242.com/owa>"? Assume ^^??? is your numbers.
   A. The SSL certificate is self-signed or not trusted
   B. The server is offline
   C. The URL is incorrect
   D. OWA is not installed

42. When setting our time zone, what is the "UTC" offset?
   A. UTC-4 or UTC-5 (Eastern Time)
   B. UTC+0
   C. UTC-8
   D. UTC+5

43. What additional groups did we add to "Member of", in ADUC for your user?
   A. Organization Management and Domain Admins
   B. Power Users and Administrators
   C. Remote Desktop Users
   D. Backup Operators

44. What minimum amount of disk space did I recommend so that Exchange can Send e‐mails?
   A. 10 GB
   B. 20 GB
   C. 30 GB
   D. 50 GB

45. What Windows program do we use to extend disk space?
   A. Disk Management
   B. Device Manager
   C. Computer Management
   D. Storage Spaces

46. What is the fully qualified server name of my mail server in the class?
   A. mail.dm^^???.cst8342.com
   B. exchange.lab.local
   C. smtp.domain.com
   D. server01.cst8342.com

47. Do you need to be physically connected to the class network to do an nslookup of your server?
   A. No
   B. Yes
   C. Only for external queries
   D. Only for reverse lookups

48. What port does DNS use?
   A. 25
   B. 80
   C. 53
   D. 443

49. What Exchange Management Shell command do we use to see User CAL licenses?
   A. Get-ExchangeServer
   B. Get-UserCAL
   C. Get-Mailbox
   D. Get-ExchangeServerAccessLicense

50. What account has mail enabled by default when installing Exchange as Administrator?
   A. Guest
   B. Administrator
   C. Exchange Admin
   D. System

51. Can you send mail to Exchange Users without creating a Send Connector?
   A. Yes, for internal mail only
   B. No, Send Connector is always required
   C. Yes, but only to external recipients
   D. Only if SMTP is disabled

52. What type of Send Connector did we create?
   A. Custom
   B. Internet
   C. Partner
   D. Internal

53. What ports do POP3 use in Exchange?
   A. 25 and 587
   B. 110 and 995
   C. 143 and 993
   D. 80 and 443

54. What port is used for SSL when configuring POP3 in Exchange?
   A. 110
   B. 993
   C. 995
   D. 587

55. What ports do IMAP4 use in Exchange?
   A. 110 and 995
   B. 143 and 993
   C. 25 and 465
   D. 80 and 443

56. In order to use POP and IMAP, what must we do in Services?
   A. Restart the Exchange services
   B. Start and set to Automatic the POP3 and IMAP4 services
   C. Disable the SMTP service
   D. Enable Windows Firewall exceptions

57. What must we do to Receive Connectors before we can receive mail from the Internet?
   A. Delete the default connector
   B. Add anonymous authentication and appropriate IP ranges
   C. Disable all authentication
   D. Change the port to 2525

58. What did we remove under scoping for our Receive Connectors?
   A. The local IP address range
   B. The server's IP address
   C. All IP addresses
   D. External IP ranges

59. Under what receive connector, is port 25 defined?
   A. Client Receive Connector
   B. Default Frontend Receive Connector
   C. Internal Receive Connector
   D. OWA Connector

60. Can you create users in Exchange Admin Center, or do you need to use ADUC?
   A. You can create users in Exchange Admin Center
   B. You must use ADUC only
   C. You must use PowerShell only
   D. Users are created automatically

61. When editing a user in ECP, under what option do we see Issue a warning at (GB)?
   A. Mailbox Settings
   B. Storage Quotas
   C. General Settings
   D. Email Options

62. What is your professors lab e‐mail address, not the College e‐mail address?
   A. professor@dm000.cst8342.com
   B. instructor@algonquincollege.com
   C. admin@lab.local
   D. This varies by student/professor

63. What is a Smart Host?
   A. An intelligent routing device
   B. A relay server that forwards outbound email
   C. A DNS server with caching
   D. A load balancer for Exchange

64. What Exchange Management Shell command do we use to change the port from 25 to 2525 on the Send Connector?
   A. Set-SendConnector -Port 2525
   B. Set-TransportServer -Port 2525
   C. Set-ReceiveConnector -Port 2525
   D. Set-SMTPPort -Value 2525

65. What is the purpose of the Log files?
   A. To track user activity
   B. To record transactions and troubleshoot issues
   C. To backup email messages
   D. To store deleted items

66. When creating a new user in Exchange Admin Center, what defines the users e‐mail address by default?
   A. The username and default email domain policy
   B. The user's full name
   C. The administrator's choice
   D. Random generation

67. What is the syntax of the command we use to test remote access to our mail server? Hint telnet
   A. telnet mail.domain.com 25
   B. ping mail.domain.com
   C. nslookup mail.domain.com
   D. tracert mail.domain.com

68. What extension does an Exchange database use?
   A. .mdb
   B. .edb
   C. .pst
   D. .ost

69. What Exchange Console command do we use to move a database and log files to a new location?
   A. Move-DatabasePath
   B. Set-MailboxDatabase
   C. Move-MailboxDatabase
   D. Set-DatabasePath

70. What command do we use to create a new mail enabled user in Exchange Shell?
   A. New-Mailbox
   B. Enable-Mailbox
   C. New-User
   D. Add-Mailbox

71. What must we do if we create a new user in the Exchange Shell and it does not apear in Exchange Admin Center?
   A. Restart the Exchange services
   B. Refresh the browser or clear cache
   C. Run Update-ExchangeAdminCenter
   D. Recreate the user

72. What is UserPrincipleName?
   A. The user's email address format (user@domain.com)
   B. The user's display name
   C. The user's security identifier
   D. The user's login password

73. What shell command do we use to move a user to a new mailbox database?
   A. Move-Mailbox
   B. New-MoveRequest
   C. Set-Mailbox
   D. Transfer-Mailbox

74. What command do we use in Exchange Shell to show disconnected mailboxes?
   A. Get-MailboxStatistics | Where {$_.DisconnectDate -ne $null}
   B. Get-DisconnectedMailbox
   C. Show-Mailbox -Disconnected
   D. Get-Mailbox -Inactive

75. Under what setting in Exchange Admin Center (ECP) do you modify warning message interval for a database?
   A. Server Configuration
   B. Database Limits
   C. Storage Settings
   D. Mailbox Settings

76. Who did Microsoft purchase the WinINSTALL program from?
   A. Symantec
   B. OnDemand Software
   C. Veritas
   D. IBM

77. What is an .msi file?
   A. A compressed archive
   B. A Microsoft Installer package
   C. A system image file
   D. A macro script

78. Can you repackage older software that does not use the .msi extension for installation?
   A. Yes, using repackaging tools
   B. No, it's impossible
   C. Only with administrator rights
   D. Only on older operating systems

79. What are advantages of custom installations using group policies?
   A. Centralized deployment and management
   B. Faster installation times
   C. Smaller file sizes
   D. No user interaction required ever

80. What is a resillent application?
   A. An application that can repair itself if damaged
   B. An application that cannot be uninstalled
   C. An application that requires no updates
   D. An application installed on multiple servers

81. What do they mean by clean removal?
   A. Uninstalling software without leaving registry entries or files
   B. Deleting temporary files
   C. Formatting the hard drive
   D. Removing viruses

82. What are elevated permissions?
   A. Administrator or higher-level access rights
   B. Read-only permissions
   C. Guest account permissions
   D. Network access permissions

83. With mandatory upgrades, if a user does not have the old version already installed, can they install the old version?
   A. No, they get the new version automatically
   B. Yes, they can choose
   C. Only with administrator approval
   D. Only in compatibility mode

84. With an optional removal, can users install an application if they don't already have the software application installed?
   A. Yes, if the application is published
   B. No, they must have the old version first
   C. Only through Add/Remove Programs
   D. Only with a command line switch

85. What are differences between published and assigned applications?
   A. Assigned auto-installs; Published is user-optional via Add/Remove Programs
   B. Published auto-installs; Assigned is optional
   C. They are the same
   D. Assigned is for computers; Published is for users only

86. What is a .zap file?
   A. A compressed application package
   B. A simple text file for publishing legacy applications via GPO
   C. A zone configuration file
   D. A backup file format

87. What is a .mst file?
   A. A master configuration template
   B. A transform file that customizes .msi installations
   C. A test file for applications
   D. A temporary installation file

88. What is a GPO?
   A. Group Policy Object
   B. General Purpose Operating system
   C. Global Permissions Override
   D. Group Processing Order

89. Beside Computer Configuration, what other corresponding section is present in a GPO?
   A. User Configuration
   B. Network Configuration
   C. Security Configuration
   D. Application Configuration

90. What type of applications are resilient? Published or Assigned?
   A. Published
   B. Assigned
   C. Both
   D. Neither

91. What is document invocation?
   A. Opening a document automatically launches its associated application
   B. Sending documents via email
   C. Creating document templates
   D. Printing documents remotely

92. What is "Net Use"?
   A. A command to connect to network shares
   B. A utility to measure network bandwidth
   C. A tool to configure IP addresses
   D. A service for file sharing

93. What is a "ZAP" file?
   A. A compressed file format
   B. A simple text file for publishing legacy applications via GPO
   C. A backup archive
   D. An encrypted container

94. Can applications using a zap file for installation, be assigned?
   A. No, only published
   B. Yes, always
   C. Only to computer objects
   D. Only with administrator rights

95. Are applications using a zap file resilient?
   A. No
   B. Yes
   C. Only if assigned
   D. Only on Windows 10+

96. What headings do we have in a zap file?
   A. [Application] and [Ext]
   B. [Header] and [Body]
   C. [Install] and [Uninstall]
   D. [Config] and [Settings]

97. What is an mst file?
   A. A master setup template
   B. A transform file that customizes .msi installations
   C. A Microsoft test file
   D. A metadata storage file

98. What are the two deployment types for software deployment?
   A. Assigned and Published
   B. Manual and Automatic
   C. Local and Remote
   D. User and Computer

99. What does it mean to uninstall the application when it falls out of scope?
   A. The app is removed when the GPO no longer applies to the user/computer
   B. The app is removed after 30 days
   C. The app is removed when the user logs out
   D. The app is removed manually

100. What is "Add/Remove Programs" called in current operating systems?
   A. Programs and Features or Apps & Features
   B. Software Center
   C. Application Manager
   D. Install/Uninstall Programs


## More Questions

- What is "Add/Remove Programs" called in current operating systems?
- What are the two deployment types for software deployment?
- What type of applications are resilient?
- Beside Computer Configuration, what other corresponding section is present in a GPO?
- What are elevated permissions?
- What extension does an Exchange database use?
- What Exchange Management Shell command do we use to change the port from 25 to 2525 on the Send Connector?
- When creating a new user in Exchange Admin Center, what defines the users e-mail address by default?
- Can you create users in Exchange Admin Center, or do you need to use ADUC?
- What must we do to Receive Connectors before we can receive mail from the Internet?
- Under what receive connector, is port 25 defined?
- What ports do IMAP4 use in Exchange?
- What ports do POP3 use in Exchange?
- What port is used for SSL when configuring POP3 in Exchange?
- Can you send mail to Exchange Users without creating a Send Connector?
- What Exchange Management Shell command do we use to see User CAL licenses?
- What type of Send Connector did we create?
- What port does DNS use?
- What Windows program do we use to extend disk space?
- When setting our time zone to Eastern Standard Time, what is the "UTC" offset?
- What additional groups did we add to "Member of", in ADUC for your user?
- What is the difference between "x86" and "x64"?
- Why do we get a warning message when we first type "<https://mail.dm^^???.cst8242.com/owa>"? Assume ^^??? is your numbers.
- In order to use POP and IMAP, what must we do in Services?
- What is "127.0.0.1"?
- What is the purpose of an MX record?
- What type of naming convention is "\\ServerName\ShareName"?
- What is a Source Starter GPO?
- What did we remove under scoping for our Receive Connectors?
- What is the purpose of "ipconfig /flushdns"?
- What would be the default NetBIOS domain name for your domain? Assume ^^??? represents your numbers.
- Is DNS Server a Role or a Feature?
- What extension is given to a forward lookup zone file?
- When we are setting up our 172.16.0.0 network, do we use NAT or Bridged?
- Why did we choose Desktop Experience when installing Windows?
- What Server Role must we add in Server Manager to enable Active Directory?
- Why did we not create a DNS delegation when installing Active Directory?
- What type of objects are "ITS, HelpDesk, Development, and CustSupport" in ADUC?
- Under what existing policy were you told to modify, to allow users to login locally on the server?
- Do you need to be physically connected to the class network to do a nslookup of your own server?
- What is a Smart Host?
- What is the IP address 8.8.8.8?
- What is the difference between Assigned applications and Published Applications?
- What account has mail enabled by default when installing Exchange as Administrator?
- When editing a user in ECP, under what option do we see Issue a warning at (GB)?
- What is a GPO?
- What does it mean to uninstall the application when it falls out of scope?
- Are applications using a zap file resilient?
- What is document invocation?
