# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

[0e75474](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0e754746a5bf60397d0f19a8c63256615c1d0b7f)...[15a9adc](https://github.com/ADORSYS-GIS/wazuh-snort/commit/15a9adc09c9a9211edca4af42c368915edbe36c2)

### Features

- Add silent installation/uninstallation support to Windows scripts and update release workflow to automate changelog and checksum generation. ([`23a3e70`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/23a3e7009dd7f4b83614da18eecd636f24b0375f))

### Miscellaneous Tasks

- Update CHANGELOG.md and checksums ([`e112186`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e112186327cf75e2e981ec94ef1c5eb65d42972f))
- Use full commit sa for github actions ([`7063f45`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7063f4520b11a5de55970f378c1806ad35f1c2b5))
- Consolidate CI and release workflows into a single unified pipeline ([`15a9adc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/15a9adc09c9a9211edca4af42c368915edbe36c2))

## 0.2.4-rc.1 - 2026-03-31

[4d6d262](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4d6d2623019861341b869ecd4a87debaad2c3ad2)...[0e75474](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0e754746a5bf60397d0f19a8c63256615c1d0b7f)

### Bug Fixes

- Updated script paths in workflow files ([`7cae414`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7cae4146dd96b2841beba1edc87c49b6f88fac67))
- Fix(ci): Drop Start-Process for windows testing ([`a2b8fbc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a2b8fbc051421566210b500f3ab31b9ed5775e7a))

### Features

- Feat(windows installer) added validation function ([`19abfa3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/19abfa36ef83d109541861f497677cfc47b1eaea))
- Add silent installation switch to Windows install script ([`fe3ee34`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fe3ee3457b880b19a29aa5daaa03b0d41c9f8519))
- Support silent installation in PowerShell script and pin checkout branch to main in release workflow ([`7c78282`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7c78282bdc8ad6a6f7e00271d8a623a2cdca0100))

### Miscellaneous Tasks

- Add git-cliff configuration for automated changelog generation ([`b6d1818`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b6d1818d09a69b1fb8d3b66aa8396bf7599e53b0))
- Update repository name in cliff.toml and simplify Windows installation script execution ([`7cee12e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7cee12e9592cdc3dc08d7e115a7d9ed4344dca81))
- Include CHANGELOG.md and checksums.sha256 in release commit paths ([`c5aae56`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c5aae56dfe20902c50fd11a57a2272d058658939))
- Update checkout ref and migrate manual commit to create-pull-request action ([`9152b0e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9152b0eb8f1851388ea38afde564506fcab31019))
- Update checkout configuration and remove file path restrictions in release workflow ([`df4d506`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/df4d50697c01cb4ffdd0057695d189d7b367b756))
- Include CHANGELOG.md and checksums.sha256 in release workflow commit ([`3a7a632`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3a7a6321c6560a915e3f96a139e57b49ff513ab9))
- Add workflows write permission to release workflow ([`aa0167a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/aa0167a5b0d6874386eb610f2cb5e7baec7a5d91))
- Update workflow permissions from workflows to actions for release pipeline ([`0e75474`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0e754746a5bf60397d0f19a8c63256615c1d0b7f))

### Refactor

- Split Linux and macOS specific scripts and logic ([`cbed5bb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/cbed5bb3151b1f7ccbca202350e46f90af38578c))
- Define OSSEC_CONF_PATH in Linux and macOS install scripts ([`c5421e1`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c5421e14847e5f8ffef5fc330c9b6e4c1d12b38e))
- Remove OSSEC configuration updates from install and uninstall scripts ([`d8b6c18`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d8b6c183d46789456f45f82f3ad23197aed7c6e7))
- Improve interface validation in Snort installation script ([`9ca46b1`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9ca46b1ccb92bfcc32e0291a44e5ad3b3ea71e6b))
- Implement common helper functions for Windows Snort installation and uninstallation scripts ([`ac8e134`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ac8e1343534520abc8974f4d30ea17ae507b6a50))
- Update common helper functions URL in Windows install script ([`a94ea59`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a94ea59d9ffd65f97092cb67e46ef57032070464))
- Remove silent mode from Windows installation scripts and update CI workflows to include PSScriptAnalyzer ([`a5351ca`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a5351ca59356f56a149d78f90001ed0336bae5d7))

## 0.2.4 - 2025-07-09

[ba47dbe](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ba47dbe0350f1390f36ec542c91b409fe2d5b9ae)...[4d6d262](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4d6d2623019861341b869ecd4a87debaad2c3ad2)

### Refactor

- Streamline Snort uninstallation process and improve OS-specific handling ([`cbd98df`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/cbd98df1b9b5f2c12b3eb3d00940432995016872))
- Simplify OS-specific path determination and improve error messaging for root privileges ([`7e2206f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7e2206f77269d7dd416bf90e6340442e5c1c0dfb))

## 0.2.2 - 2025-02-24

[9ed01df](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9ed01df7c2cc05c31a6cfbaf066fa56594da39e7)...[ba47dbe](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ba47dbe0350f1390f36ec542c91b409fe2d5b9ae)

## 0.2.1 - 2025-02-19

[33f60a3](https://github.com/ADORSYS-GIS/wazuh-snort/commit/33f60a35a2c9eef2f813ab9e58c03858fc553ffc)...[9ed01df](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9ed01df7c2cc05c31a6cfbaf066fa56594da39e7)

## 0.2.0 - 2025-02-07

[a90b740](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a90b7401c23d011b19973b748454329e37e46793)...[33f60a3](https://github.com/ADORSYS-GIS/wazuh-snort/commit/33f60a35a2c9eef2f813ab9e58c03858fc553ffc)

## 0.1.1-rc3 - 2025-01-28

[3db3a9f](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3db3a9f35e8c402f868e2b31edcd033f5e2818a0)...[a90b740](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a90b7401c23d011b19973b748454329e37e46793)

### Bug Fixes

- Update download of snort rules taking into consideration read-only plist env for macos ([`a90b740`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a90b7401c23d011b19973b748454329e37e46793))

## 0.1.1-rc2 - 2025-01-28

[948dd1e](https://github.com/ADORSYS-GIS/wazuh-snort/commit/948dd1ebdfa7005acebff78b2d155b7a56034ad5)...[3db3a9f](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3db3a9f35e8c402f868e2b31edcd033f5e2818a0)

### Bug Fixes

- Add function to get logged-in user and use it for Snort installation on macOS ([`c79c318`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c79c318664dfc226f0964d6064b3b96673a45130))
- Refactor Snort installation and uninstallation scripts to use logged-in user for Homebrew commands on macOS ([`bdb4c07`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bdb4c075ae32714da810d5a126f72bee2b496f8c))

### Miscellaneous Tasks

- Improve idempotency in bash uninstall script ([`4cc5e38`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4cc5e384c523595709410c2c97bcc0a84c2081c1))
- Improve idempotency in bash uninstall script ([`da9bc42`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/da9bc42362727c52e0da6d790a1432ae2dabebba))
- Improve logging in uninstall script ([`745831b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/745831bb1f694d16d7662599beb54cf9467a484d))
- Install snort if not already installed ([`08404eb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/08404eb2f3f17232e9ad7934c4baaae4ad3a836b))

## 0.2.3 - 2025-06-05

[8ff1216](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8ff12168020b09d777f208076682cd1eb6103870)...[948dd1e](https://github.com/ADORSYS-GIS/wazuh-snort/commit/948dd1ebdfa7005acebff78b2d155b7a56034ad5)

### Bug Fixes

- Obtain snort3 rules from the snort repo ([`0c90c88`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0c90c88439def4d704df2ebd3daf38161b419d99))
- Obtain snort3 rules from the snort repo ([`a81b226`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a81b226a308b2d825df1df97ad34b85ca791793b))
- Obtain snort3 rules from the snort repo ([`9eabe99`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9eabe9963fb7ca4b4683324c34062fe81b3ceb72))
- Obtain snort3 rules from the snort repo ([`ad8cc3b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ad8cc3bc6866e613d119555b7a0c08eb1bea0a64))
- Obtain snort3 rules from the snort repo ([`7db6a68`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7db6a688613152c76f1ec00abc2014bbe7abbb59))
- Ossecconfig Path was not mentioned ([`a3aee91`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a3aee91aa6046f29cd800003dd233c45e9e06590))
- Check if service exists before restarting ([`3d197df`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3d197df8bf297647336d401baca5f0022b8852b0))
- Add check to see if snort or npcap is installed ([`4cd82f0`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4cd82f012ecbf4cc01ee5423166d7d0f50b17af8))
- Modularize installation script and Improve Logging ([`1034878`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/103487814171b4d5f9a7ecc7005cf34f37629cd2))
- Remove next line  in snort main function ([`4996d78`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4996d782c991b17bcf2ee9cf059656e732563022))
- Remove whitespace for brew_path variable ([`834dd65`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/834dd65a7306b9388a085cc58864f6781d289e09))
- Register Snort scheduled task to run as SYSTEM at startup with hidden, battery-friendly, and network-available settings. ([`2954981`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2954981d49c7be2718b52fb56e7a7dffc71a7e0b))
- Remove interface and -A console arguments from snort scheduled task command ([`5b2405c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5b2405c4478a8b154bc1c03ab61429bf58eeddbc))
- Update expected content in linux test update conf function ([`fae3037`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fae30370101de0bc2a39c06917fb0e9d3d4fba45))

### Features

- Initial Snort Uninstall script commit ([`be5edfc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/be5edfcc3fbcca336428e1f5dc2c17e0bac4f25c))
- Add uninstall script ([`5a5732e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5a5732e52fff5fcb3c4956e879efafdfc797f326))
- Snort uninstall script ([`29e6b8e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/29e6b8ef0389184a7e4e2d4b12e2a4407cae0a2a))
- Add check to see if snort config exists in ossec.conf ([`6844125`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/684412545af1559623d6ad2a1c07c6143d9c2a82))

### Miscellaneous Tasks

- Make snort launch at startup on macos ([`06ecfb5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/06ecfb51104e55d337c9a80e8390e85130f8a256))
- Improve logging ([`9ee6471`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9ee6471bcde994a56ac09899be313d1995dc6e06))

### Testing

- Use PsExec to launch snort installer ([`9906967`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/99069677b67dea1cd7df253b94934e7b3c7f7cf9))
- Add wait and quiet ([`308894f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/308894ff512eab9e6d8d1675352739deb43567a3))

## 0.1.1-rc1 - 2025-01-27

### Add

- Setup configuration for snort on linux ([`ecc5226`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ecc52262833817df097e278d0987c5a70a84d54f))

### Bug Fixes

- Test docker ([`5b41527`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5b415278d41933cc1783462308becdc88707d04b))
- Ci ([`1ae3565`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1ae35659067844a18be48520edfd17b4c0f9ecea))
- Prevent duplicate Wazuh repository entries ([`39e3920`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/39e3920b23a764c4168e1b4809fabe37a3d010d2))
- Resolve permission issues in Bats tests ([`2e0c533`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2e0c5335349563d928c4af3eee95599a02cc5aa7))
- Fix snort 2  config to snort3 ([`a6d9013`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a6d90131759dcb68d7e963619eac54d631dc5e51))
- Update snort script to support and set dynamically multiple NIC and HOMENET ([`8457bf2`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8457bf2c1c1d7294d1a056d851278793d84e0c78))
- Fix : tests bats snort ([`e0743ce`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e0743cea675ebe5caca6147626552a843ebdb7bd))
- Correct indentation and formatting issues in test script ([`96be6bb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/96be6bb4df45645f8f9f9da6a095d9281fa78bb8))
- Update snort.conf with correct HOME_NET configuration ([`b51d936`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b51d93626ebe9f1fd7204bd6454cd32d6427c89c))
- Resolve issue with grep not detecting multiline content in ossec.conf update ([`61c5587`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/61c5587abbacfceee6ca81b30b7804df5859d19d))
- Replace Curl commands with Invoke-Webrequest ([`c0a833d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c0a833d2efa1482d0fd101dcdda14a55e57d3164))
- Update raw file URL's ([`97cc4ca`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/97cc4ca53ced7c66bce586f5bbf32662d74a5f1f))
- Add User-Agent header to bypass Cloudflare in Snort download ([`da9301a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/da9301a937b7db3a37b04349bc6478b73a1fbb56))
- Fix/change INTERFACE variable to get all netwrok interface excluding virtual ones ([`ef3af21`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ef3af21d16803068019005b9f51ce246d696eb1e))
- Completey remove snort folders when uninstalling ([`6f114c8`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6f114c851d645ce859d3904b22e35b1d5a239c9b))
- Add missing sed_alternative command ([`915d0b9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/915d0b9b015df4f1fe562b78fcae41cb913010c5))
- Add missing sed_alternative command ([`69acefb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/69acefbd2a9a61da950f2e5fcfce99faeb4bda39))
- Add missing sed_alternative command ([`bac5604`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bac5604b745d5f075c308a97973dfb2ce9c711d5))
- Improve funnction to revert snort config in ossec.conf ([`03be316`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/03be3169e6fdd3668c3131ae9130097ff646470c))
- Syntax error line 106 ([`48905d7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/48905d7fdada1a66ff9699c7f5f879bf224eb384))
- Improve sed command usage ([`5748810`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/574881078ba126463205e038bfd2d55173d6e145))
- Added check to see if snort config in ossec.conf exists ([`4a99399`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4a993994912e5b836f3a2a0742884c1ef3abc4c6))
- Updating spacing ([`c68a1c3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c68a1c33a0d1f3a13f143555c3d85d9b1b7ea36b))
- Change method of snort config in ossec.conf file to use XML based approach ([`35616af`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/35616af90b73b7d889ce5b7cb92376441d01d2dd))
- Update ossec configuration in linux ([`15b5250`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/15b5250a8a824c37ffdd441b83422be906783ec6))
- Update community rules link for macos ([`6ba7bf7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6ba7bf72c664b83bd4ab1c6557fdb124bbb36023))
- Start snort3 using community rules file ([`62be405`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/62be405c9ea06a0eb50b8ba73d1bc019db92e4c0))
- Use community rules for snort 2.9 on linux ([`f531cc2`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f531cc202cb678f7f45c21b5bda79b6060680d0a))

### Documentation

- Add concise README for Snort 3 build and packaging ([`e795fa7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e795fa7ce1e9147cbe5f3723e6f90dd6be0f6a1e))

### Features

- Feat : add powershell script to install snort on windows Os ([`8726ff4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8726ff43ea710f942fc63a7b5300236a22736b7b))
- Add snort .conf sample config ([`b263d21`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b263d21f0f81a261204e40a027d785474caa9dc9))
- Add wazuh-agent installation step to GitHub Action workflow ([`e2b41ea`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e2b41eac4d85d5e6f573ac6992fb008c354c8f66))
- Update GitHub Action workflow to run tests with elevated permissions ([`273b717`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/273b71760287ff82322a16931626921aafa69965))
- Update snort.conf with correct HOME_NET configuration ([`faba06e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/faba06e67ba36686cf94bb726b3338bbc07c7e8f))
- Feat : add snort.conf for windows OS ([`07a4548`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/07a4548ba3125f97dc6455cd5798b1900e9151d4))
- Add snort local.rules ([`8933c0d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8933c0d2790d34468c953b7bc81a3778801a8032))
- Add uninstall script ([`acf2e3b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/acf2e3bf2482058590861c9bff0b96ca2777a9f1))
- Add installation validation steps ([`50cc682`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/50cc6823d4325e2bdee6c2b275cf856c06c54ac1))
- Add OS check to configure snort config files for Debian-based systems ([`b3ab5a2`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b3ab5a21c3e2dfc0ac7c63a7c4c52ce7530be863))

### Fix

- Added check to see if scheduled task already exists ([`eb7f62c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/eb7f62cd372f15705ee213db2ca908095d32ae51))
- Changed Interface variable to store on one line seperated by space. ([`2ae955d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2ae955d798751ba84ec71858856686c620e7d20e))
- Change confi_snort_interface function to update snort.debian.conf ([`a3c302d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a3c302db3b792a449882500e0f46826e3299f2f9))
- Changed colon to equals in snort interface config function ([`f003109`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f0031099e9b3ac9be5fbf2b91f91775c1b5273c0))
- Function to update ossec.conf on macOS ([`b21e73b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b21e73b31f1dc2e728875b81357b40b15ae2c672))
- Function to install snort on Linux ([`eaab083`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/eaab083c3b06c2fc572e4b2e18ecc6c80d3da1df))
- Function to install snort on Linux ([`55ffa36`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/55ffa36e887e15b629fc80e1d781c5133611e3c9))
- Function to install snort ([`d5b398d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d5b398d79a74844094b2a1d35d24fd4144131900))
- Function to install snort ([`fea1589`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fea15894326594b23a27086bbaead9ab698aadb9))
- Setup configuration for snort on linux ([`edf1f49`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/edf1f49ecda4a6df2f77755137320a65226f0bad))
- Setup configuration for snort on linux ([`b34013d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b34013d2875d896589bbee5e59557f1d13c46144))
- Setup configuration for snort on linux ([`bc593cc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bc593cc326d871e0bfb2323beb294d6f079b4f16))
- Setup configuration for snort on linux ([`9094883`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/909488385d741dc26e317895126ce7eb57ae61e8))
- Setup configuration for snort on linux ([`b71b066`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b71b06698f6dc2299d3d0902e6fa3528011fa343))
- Setup configuration for snort on linux ([`7ec32a5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7ec32a524666018236b907c05d86cec46dae6887))
- Setup configuration for snort on linux ([`e13e60a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e13e60ae193c09591ab42296e7af15fd7c8dbba1))
- Setup configuration for snort on linux ([`9010048`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/90100485b85396c2d0f3a974cff7606795fb05cf))

### Miscellaneous Tasks

- Initial commit ([`a5668a4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a5668a496d4d6d31568ae85e90a6a66cca1baf64))
- Testing using bats ([`e9a4d85`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e9a4d8564d3cbd5479be378c9e6196d5c378b4e2))
- Testing using bats ([`f6d7384`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f6d73845c67ed6329a5e9adb0923da77a3dc59a3))
- Fixing script for linux ([`6383f34`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6383f3408e6116f97ff4f123e947d9a15808c240))
- Update README with detailed description and instructions for Snort integration with Wazuh ([`379bdc9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/379bdc9ac99120125953ab5b6a101af041400f73))
- Update script to use correct path for installation ([`d2e0b19`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d2e0b19c1c2c1ecd2f3868964a3816d0bfa6051e))
- Update script to use non interactive and install net-tools ([`e67579f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e67579f0b467192f48c157edef8e48a8c0d1450c))
- Change ownership and set capabilities for Snort binaries on macOS and Linux ([`d8837eb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d8837ebc0dc4196d775cb8ae632c3c1b04e690c8))
- Comment out Snort startup command in start_snort_linux function ([`31758b4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/31758b4ec7088c99bfd62c13e9b722768eb3d173))
- Add snort user to adm group and update permissions and ownership of snort directory ([`66a5f9f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/66a5f9fca66cbae1fff9f3b70de5cc578ec487fa))
- Restart Snort and update ownership of snort directory on Linux ([`731cea9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/731cea941220fec6147af02657e67c5ff6402167))
- Update Snort test script to improve reliability and readability ([`6bb380d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6bb380d0379930e2b42940c8e7dd00acca84a2e0))
- Update Snort test script and improve reliability and readability ([`648aa08`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/648aa0851c84bd8f845c5e865d44b0461b42dffa))
- Update test script to use latest bats Docker image ([`6ee0242`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6ee0242e3dd8d71e76b86ef4627ac669bdca8cb5))
- Update test script to use latest bats Docker image ([`e492937`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e49293763eaf44a6e882be9caa196422d8d6e536))
- Update Bats test script to use latest Docker image and improve reliability and readability ([`ad878a8`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ad878a8eb254a649ef7ba2288863d720feb505fc))
- Update Bats test script to use latest Docker image and improve reliability and readability ([`97fd419`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/97fd41993b015c091224acf77c9b3790802764a2))
- Update Bats test script to use latest Docker image and improve reliability and readability ([`62c981f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/62c981f92f9ab16d03eb98431423fb4d2e2fb9ee))
- Update Snort test script to improve reliability and readability ([`5612bf1`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5612bf1de15b45a299821a8064838b23eba4afc5))
- Update Snort test script to improve reliability and readability ([`65a264e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/65a264edacffbdff00b683b18ea537e5af38b3e8))
- Improve reliability and readability of Snort test script ([`e375e3c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e375e3c3f3c63acd6820bb1cd9e6791a4c878b82))
- Remove unnecessary tar archives and update Snort test script ([`b203bb4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b203bb4e227910976a2caf54536b1005f5570044))
- Update Snort test script to start Snort if not running ([`604b526`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/604b526b00563a98d14c8c450d3621244954c24c))
- Update Snort test script to remove unnecessary sudo command ([`0ba098a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0ba098aad7970b65c3d4ef3d6bcf535e8bd44f11))
- Update Snort test script and Dockerfile for improved reliability and readability ([`58e0d87`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/58e0d873e068abe02b58f46e77c484f5961a809d))
- Update Snort test script and Dockerfile for improved reliability and readability ([`afe5599`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/afe5599ba71d09a9248343de8f518da81196ae8e))
- Update Snort test script and Dockerfile for improve snort build workflow ([`1d8d8c9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1d8d8c9818c395ecd0c15053bbc6c0b2b07cb68f))
- Update Snort test script and Dockerfile for improved reliability and readability ([`aaa3e14`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/aaa3e14dcbc8c18187ade258f6daa59c24982bef))
- Update Snort build workflow for improved reliability and readability ([`b57b3ee`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b57b3eece897a0a03c64d16b6047c1474a328c52))
- Update Dockerfile to use git clone for installing LuaJIT ([`10ef4fa`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/10ef4fabfdaeadd9798368fe3c000e936a1da812))
- Update Dockerfile to use consistent indentation for context property ([`0ff43bf`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0ff43bf93a23cbfc46354972a59b2628da0e1eb7))
- Configure Snort to use the main network interface ([`35d84ae`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/35d84aeb1c412c0230462841a452d7c2dd15f8b5))
- Add workflow status badge to README.md ([`f284898`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f2848984190aa8887aa44c55512b73f4af5cf096))
- Update Snort build workflow to include package creation and artifact upload ([`bb9bbee`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bb9bbeeedd4356d4e0a26c4d1b82328049297dd6))
- Update Snort build workflow to include package creation and artifact upload ([`2071f50`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2071f50bdc22167e8724b8c6f391cd0b15a9f9d2))
- Update Snort build workflow to include package creation and artifact upload ([`c73050f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c73050f1fa599fdf29b2850c19d610d3f10c3f9e))
- Update Snort build workflow to use /tmp/work directory ([`696c9d1`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/696c9d1480f95c10fb86219be8dfb705f5dea4b7))
- Update Snort build workflow to use /tmp/work directory ([`9614734`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9614734c75902144ba8fea6cbbf24af6912b633f))
- Update Snort build workflow to use /tmp/work directory ([`8db384e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8db384e2690b3b4e6bf8902322f2226b2a9d6afb))
- Update Snort build workflow to use relative paths for script execution ([`cca2b1f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/cca2b1fb7ce1b776d8d757102cb1e90403dffd01))
- Update Snort build workflow to download libdaq and set permissions for download directory ([`69c3d7e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/69c3d7e642f3b1132f7eec13b862bd00e5bcbfa1))
- Update Snort build workflow to remove go github action package ([`272f3bd`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/272f3bd1b701ef802e7bffcad0630b6cca44498d))
- Update Snort build workflow to clean up work directory and set permissions for work directory ([`7e166e6`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7e166e6a892952b27f6831bdc920d50821e6fb32))
- Update Snort build workflow to set permissions for work directory ([`e8a00c3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e8a00c39987215306517c54d6e3cd9ce1c4d7879))
- Update Snort build workflow to set permissions for work directory and clean up work directory ([`ada2b79`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ada2b79646bed3f6a54c74fe439a938aff0568d6))
- Update Snort build workflow to use checkinstall for package installation ([`cfbd6fb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/cfbd6fb4c89b5276a799e704618c8a685fcea519))
- Update Snort build workflow to use Snort version 3.2.2.0 ([`8ad5e1e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8ad5e1e512cdee04fb66996821ccbdde2f50e8e9))
- Update Snort build workflow to create release and upload release asset ([`2d4e0b0`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2d4e0b053bf069d8ed603178e42c1265a8ea0630))
- Refactor Snort build workflow to improve package creation and release process ([`fa4d26f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fa4d26fea1922e5f8c136d64c055ab5c4952e0c0))
- Update Snort build workflow to upload Snort package artifact ([`c842894`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c842894042a781aeb2ae6689896126922024312f))
- Update Snort build workflow to list build directory contents ([`a0abace`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a0abace628f78ec063cc3ee270800119eea6bc44))
- Add debug statements to Snort build workflow ([`bd699d4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bd699d4f83409941895823b8e3f4e56fdfdd0f7b))
- Add debug statement to check if the build directory exists ([`be531b1`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/be531b1c0dce4d26410418612ff14ec9811b4976))
- Update Snort build workflow to remove unnecessary build directory listing ([`6c0875f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6c0875f396bc15cc05f817190ff91a2e329af303))
- Update Snort build workflow to use dynamic architecture in package path ([`e04c101`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e04c1010111557b648c7de8824b956c23ff548e7))
- Update Snort build workflow to use dynamic architecture in package path ([`dd83b88`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/dd83b88cbc648fbc33906e59642715f1b2cce47b))
- Update Snort build workflow to use dynamic architecture in package path ([`e833f80`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e833f80c780c6e9d2ace5b829d70f69b287c2229))
- Refactor Snort build workflow to improve package creation and release process ([`daa6d37`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/daa6d37caebc1d900b2c73addc475a2acec3c903))
- Update Snort build workflow to use dynamic architecture in package path ([`af688fb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/af688fb6e7da2a37c9b95c916155f700188cfd07))
- Update Snort build workflow to use dynamic architecture in package path ([`6c15d71`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6c15d71858c05db6b460b5fb168233cf7e98e1e5))
- Update Snort build workflow to use dynamic architecture in package path ([`eac6bf3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/eac6bf3e57b82850ebc5d1ad6bc8a06b5d13432d))
- Update Snort build workflow to include build directory listing ([`fffa99f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fffa99f96a8afd574b5bea7c7b3fde76c8c726dd))
- Update Snort build workflow to use dynamic architecture in package path ([`c33738d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c33738d89a5d2055f3583cf3f4f5b7fdf57c7e2b))
- Update Snort build workflow to copy generated .deb files to the designated work directory ([`b0b7c4d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b0b7c4d991447b930d9e1036acd883d702b6515a))
- Update Snort build workflow to copy generated .deb files to the designated work directory ([`843663e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/843663e0996897d81aef6a630168042fbb736412))
- Update Snort build workflow to copy generated .deb files to the designated work directory ([`caba4b5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/caba4b5dce9f1f6f0263568da02afb082771f8b5))
- Update Snort build workflow to create a work directory for package artifacts ([`fcfd8bd`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fcfd8bd4384a6e264632e49eab442ae3391bdc46))
- Update Snort build workflow to include dynamic architecture in package path ([`b928f51`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b928f5188cd42d3ebb9c3fc6b44ea2f34c912efc))
- Refactor Snort build workflow to improve package management ([`55af43d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/55af43db0153aa1fef03709d67b331370882ac37))
- Update Snort build workflow to publish .deb packages to GitHub Releases ([`f0ed163`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f0ed16327e330c73cbb15ac25702a841799d8398))
- Update Snort build workflow to remove unnecessary clobber flag in release creation step ([`c1c8669`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c1c8669d62a9faaa4150ae771fef2baefcaa137a))
- Update Snort build workflow to remove unnecessary clobber flag in release creation step ([`a8c02a3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a8c02a384a95176b3c41bccf7b0128fe3ebfb09a))
- Update workflow to package Snort 3 with dependencies into a single .deb file ([`67e3304`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/67e33041c93bfc37e0206a1cff8e531a41d2e655))
- Update Snort build workflow to include GitHub token in environment variables ([`adf624a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/adf624a3fc041eaa875401b55496750a53999ae9))
- Clean up Snort package creation process ([`5fc9ded`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5fc9ded3b32b48c9d218986eddd41216faba8132))
- Move Snort package with correct filename during packaging ([`8055544`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/80555446912a009eaa6c26f9e7dd35c9f3823c46))
- Simplify Snort package naming during packaging ([`19cdcec`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/19cdcec6c8c34707d619f91ddaa381fc38d454fd))
- Improve Snort package naming and move with correct filename during packaging ([`2fb032b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2fb032b3452cd97e19d2618040154297d3b5ae5a))
- Move Snort package with correct filename during packaging ([`633bb36`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/633bb36902aaddc4291ae43d0b8e15752564112e))
- Refactor Snort package creation process ([`6579c73`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6579c7389c660a826a6727b3c95217b70d483d35))
- Publish Snort packages for amd64 and arm64 architectures ([`1425dae`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1425dae4246490ab8beaf44e1d8620866e6b213e))
- Update Snort package creation process to download and publish all packages for different architectures ([`13a96fc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/13a96fcf7cc2260d6eab7eb2cb4e1b5f87a3d9c5))
- Download and publish Snort packages for different architectures ([`90ec742`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/90ec742d6f0aba91791882d44e298c701a4c4939))
- Update Docker actions to latest versions for Snort package workflow ([`13df967`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/13df967d506040753ebcd001e92a1e405d855bdd))
- V1.0.0 ([`b3d0933`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b3d093357d7232791a51eec266af1c31aa6ea8b7))
- Publish Snort packages for amd64 and arm64 architectures ([`2beba01`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2beba011a8bf5e76295ddd8c8c184d81e684fb8d))
- Move Snort package with correct filename during packaging ([`4ba566e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4ba566e1b41e1444d6f3daa558c88b4fa76c0a30))
- Refactor Snort package creation process ([`bea11c3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bea11c3d07bfb590924060cdd969c6a98dce122e))
- Update GitHub Actions workflow to use github.run_id for tag and release name ([`b93d779`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b93d779fa0ec9252a4b580d8f09528a8b0c187ba))
- Refactor Snort package creation process ([`564ec3c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/564ec3cbc53616d84d215af8bffa752fe4cd6dd8))
- Refactor Snort package creation process and update GitHub Actions workflow ([`c177f64`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c177f64fdb2db645787bb376df5bbb31995f4421))
- Refactor Snort package creation process and update GitHub Actions workflow ([`e52204b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e52204b89f8d990be9662642fbfa2070e367807c))
- Update Snort version to 3.3.4.0 ([`8102518`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/810251815aace224db2a5b58a37f6f3ce5f9a8a7))
- Update Snort package creation process and GitHub Actions workflow ([`9bd3f68`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9bd3f68311a85f27d1c2e62466922dc0ec38587d))
- Update Snort package creation process and GitHub Actions workflow ([`d6982b3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d6982b3632c6e9c07b1c7b69e5c92378f83517c3))
- Update Snort package creation process and GitHub Actions workflow ([`f04f961`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f04f9614b1fd36c79d2823a405cf1c9616312755))
- Refactor Snort package installation process for Linux and add README for Snort 3 build and packaging ([`9a05d50`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9a05d507d836e4bf3d670be5e154177c9c3dd19a))
- Update README with detailed information about the repository contents ([`58468a7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/58468a729fbe4036e14c9f46fe05ac40542c2870))
- Update README with concise instructions for using the resources ([`92cb8f4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/92cb8f47b8a6266356c66fa302d836394a617b9f))
- Refactor Snort package installation process for Linux and update README ([`a43d5be`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a43d5be4c6584fa0ac858d57493f666b82c598c9))
- Add snort tests necessary permissions ([`a30b335`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a30b335323490940da6af558ca22f14de2d787a2))
- Update Snort bats tests and add necessary permissions for snort tests ([`66cf6eb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/66cf6ebf199ca462564f90ce2c4297303aede32f))
- Pytest add testinfra import module ([`730eafb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/730eafb65bcc5b0962a552632b2f6f7c9fc63986))
- Add .pytest_cache to .gitignore ([`37be3b7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/37be3b75aa170f6ec6a9646aa22fd25a50467c8d))
- Update pytest command to use sudo for running tests ([`ceb8d15`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ceb8d152db486bae22346576247b18f8342577e1))
- Update pytest command to use sudo for running tests ([`5fa1bf9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5fa1bf935b3e6fbf96a6a5a03c7e4ffcb83ac146))
- Add test to check network interface in the snort.debian.conf that snort.conf use ([`fb3dfb4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fb3dfb4c27c78f965df507d94d483e7932bbef85))
- Refactor Snort package installation process for Linux and update README for Snort 3 build and packaging ([`adc964e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/adc964e61a5397eb4fee46c63734aea5c7542cae))
- Update readme for tests instructions ([`546a30a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/546a30a2d791dcb9e8ba2837129b121c1cae3508))
- Update Snort test script for Windows ([`5ca7735`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5ca77358fef45072b6eaba1535ff05e6e7c37e60))
- Update Readme ([`6c48ea9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6c48ea98c4e813436d0ca2d3fd6b7e60befec19f))
- Update package-snort.yml to trigger workflow on push to main branch ([`15ad98c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/15ad98c07eb2fb6bc7aa5ec242102db1ca171d84))
- Update Snort installation script for macOS ([`173a6f5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/173a6f55d923e46c2c6519617594bd6d567fe402))
- Update Snort installation script for macOS ([`a515ef5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a515ef56efd5e4a4985684a004e23fbf5a1ac332))
- Update Snort installation script for macOS ([`da0e77b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/da0e77bc2c5cbbf4d47f8048b95c2589a6560a70))
- Update Snort installation script for macOS ([`1fa1beb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1fa1beb1ca6a003bd91d446cd3ee7c7978a5a670))
- Update Snort installation script for macOS ([`54dade7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/54dade7aa3745b4de7b0684c1d406640514ac407))
- Update Snort installation script for macOS ([`64d6568`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/64d656870e3ed4357963c648650117f446178914))
- Update Snort installation script for macOS ([`868e486`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/868e4864d60363d7987db063d7d85c5e0bd9b123))
- Update Snort installation script for macOS ([`cb683f6`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/cb683f605dc705d9d82d2167a143a036e4024494))
- Update Snort installation script for macOS ([`67adb10`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/67adb10bee697037b3b1a34cc4d0a4966424a369))
- Update Snort installation script for macOS ([`5edea25`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5edea25e5920251db234ede4f51dcc3143f567e9))
- Update Snort installation script for macOS ([`28903df`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/28903dfec40ba692d671ac3a6c4699f3ca640637))
- Update Snort installation script for macOS ([`fb841b0`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fb841b0bbdbc789107251028fa7d5e99babb8778))
- Update Snort installation script for macOS ([`965ef18`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/965ef184841824a0c78936ea65b373481cd66888))
- Update Snort installation script for macOS ([`8e048c7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8e048c7bdefffdebec3f27787165f1957fa6df3b))
- Update Snort installation script for macOS ([`4e34825`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4e34825bd0bf1e706b6519212c444198e35f19d7))
- Update Snort installation script for macOS ([`000fe37`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/000fe37d3aadf36647642ba7ed0e918751e6dfad))
- Update Snort installation script for macOS ([`583ce56`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/583ce56f528bea7484cf4fbd5000fe99008a389f))
- Configure Snort logging on macOS ([`8973302`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8973302cbff2ed04903026cc599a0680d254d428))
- Refactor Snort installation script for macOS ([`03dde42`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/03dde42667d7d50f9f171c1f4de219ab866d0d76))
- Update Snort installation script ([`3d32b79`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3d32b7948e625399a856e0bb8524771825768ff8))
- Refactor Snort installation script ([`c799369`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c79936906780bf6557dbfb2cf22abe26b23a6c05))
- Update Snort installation script for macOS and Linux ([`7517a26`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7517a2623d7c61404c9ee35d83f82b660d500a73))
- Update Snort installation script for macOS and Linux ([`b0f1a70`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b0f1a70794f0868219a124552d3d99bb2f0dc35b))
- Update Snort installation script for macOS and Linux ([`04f5014`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/04f50141b60ec8d2144d8e2dc791a0f1d59c3655))
- Refactor Snort test for macos ([`d060e81`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d060e810bf250993ba4d7d775b2aaf6999962d13))
- Update Snort test script for macOS ([`7285f02`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7285f0250c3e53358bef1b5124f6e06e0f388c94))
- WOPS_VERSION -> 0.2.13 ([`6460fae`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6460fae93facd84d6b24ae8a34fe262197847033))
- Improve snort uninstall on linux ([`7dc0157`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7dc0157ee624f1aa60ce1ff13ece2c426a19b6b2))
- Configure snort rules in macos installation ([`fbfc107`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fbfc107fb25a2a61ec8be18dd24087800cb94796))
- Add snort config in ossec.conf only if it doesn't exist ([`f8cac08`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f8cac08505c5210b17df6acc28da6c7c6fc9c4d0))
- Use snort full mode on macos ([`8499fb3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8499fb3a51ab5d3af025a02bfa49dac85657dfb6))
- Specify snort rules in conf file on linux ([`1389ac4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1389ac4677be6abc093016192f4e95c9b01a4edd))
- Use snort full mode on macos ([`448fbb9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/448fbb97105dc2856ecc595a204aec20431a7379))
- Use snort full mode on macos ([`68199ac`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/68199aca031cb5ef1639d21ce093d5351b442256))
- Add release pipeline ([`8ff1216`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8ff12168020b09d777f208076682cd1eb6103870))

### Refactor

- Update Snort bats tests ([`550f55b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/550f55b7ee2d885da34bf8ecbcc53b81ba709d26))
- Update Snort bats tests ([`9dceb46`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9dceb4628d4ca51e59bcc492aa524115978d1671))
- Update Snort bats tests ([`4fd2587`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4fd2587b9fd21baafb7987b923fc42209f5af8bc))
- Update Snort bats tests and improve installation process for Linux ([`24ff3e0`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/24ff3e08f4edcaa65e23527c72686b7a9a710c28))
- Improve Snort installation process for Linux and update bats tests ([`d630422`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d6304222ff51a505b2b234d24965ea9a4b6475d8))
- Improve Snort installation process for Linux and update bats tests ([`640445b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/640445b2de5198e44396931b02948f0dc04412e5))
- Improve Snort installation process for Linux and update bats tests ([`87a8d2f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/87a8d2f8246f5709bfd8417644016a93ca6dff33))
- Update Snort bats tests and improve installation process for Linux ([`d9dcdb6`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d9dcdb6aa2b9d81640527370a607aacd135b9885))
- Improve Snort installation process for Linux and update bats tests ([`8f84251`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8f842510de4a6aa45511036e89902f5da3e5ca4d))
- Improve Snort installation process for Linux and update bats tests ([`7907610`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7907610e8f9cc7c41a810df052331bea4f00e6ea))
- Improve pytest ([`d309f76`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d309f766bf1ae702fa6556a23d6fc4ae2b96ba00))
- Update snort.conf HOME_NET configuration in test_install.py ([`6b43c0c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6b43c0cc46ede919fe73468544666f8f0a4bc787))
- Update snort.conf HOME_NET configuration in test_install.py ([`b30fb9f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b30fb9fcdfdec7fc912467876dd49ecc6b118333))
- Update snort.conf HOME_NET configuration in test_install.py ([`b372307`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b37230789036007939e7a69a148b8072261ef4b9))
- Update snort.conf HOME_NET configuration in test_install.py ([`8e3c4ca`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8e3c4ca09aa10ca85b13c3c1bf1578c014be2670))
- Update snort.conf HOME_NET configuration in test_install.py ([`b29285a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b29285a61595788230f5ec264cb855700e36f8c0))
- Update snort.conf HOME_NET configuration in test_install.py ([`706f237`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/706f23793a0691fcd719fd22bf7ca41ed9a8f18c))
- Update snort.conf HOME_NET configuration in test_install.py ([`ea1269c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ea1269cde79ee8be415e4895460283fe525ad795))
- Update snort.conf HOME_NET configuration in test_install.py ([`ba47b3c`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ba47b3c1473504fb1aa6319afc386a32cbee709b))
- Update snort.conf HOME_NET configuration in test_install.py ([`f553cd7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f553cd76bac41170f92171e9bd3e03e521a28498))
- Update snort.conf HOME_NET configuration in test_install.py ([`3ad8bc3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3ad8bc3d2d55ac45de969a608abcfbebd7c2a0d5))
- Update snort.conf HOME_NET configuration in test_install.py ([`8bf1408`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8bf140828f51b2533b2fa952732bd4a3fb666a68))
- Update snort.conf HOME_NET configuration in test_install.py ([`fd6c931`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/fd6c9311d6a35188efeb7c7cd6308cd63564bf8d))
- Update snort.conf HOME_NET configuration in test_install.py ([`b701310`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b701310f9b3cf876418c7105b72b13cc90a41b04))
- Update snort.conf HOME_NET configuration in test_install.py ([`d0c1b04`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d0c1b041ccbd793397f6e6ca7baa8a0fa12f6176))
- Update snort.conf HOME_NET configuration in test_install.py ([`5bcb308`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5bcb308aa0b036a27bff81f6002648ca9d5fabe1))
- Update snort.conf HOME_NET configuration in test_install.py ([`9459a80`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9459a80156373d70ea803ef461dd344b1f652fd1))
- Update snort.conf HOME_NET configuration in test_install.py ([`93965e7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/93965e7c3ff7a5bb96b08712c245b3d7359ee8ea))
- Update snort.conf HOME_NET configuration in test_install.py ([`8070d04`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8070d04317471f5e0f444dedbb1cc8071526000f))
- Update snort.conf HOME_NET configuration in test_install.py ([`876edf9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/876edf9169d84fc12a9e150fa93e125b54ab9813))
- Update snort.conf HOME_NET configuration in test_install.py ([`d9154b8`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d9154b8c90da7e7d4f5d2ff92a2108d08fef91d8))
- Update snort.conf HOME_NET configuration in test_install.py ([`2fbb9f6`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2fbb9f640e5b138da0433d2915cad8890ddd71f5))
- Update snort.conf HOME_NET configuration in test_install.py ([`3f65722`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3f6572283dc81e72e8b359200894cb95c0a51ad0))
- Update pytest workflow to increase test verbosity ([`e377faa`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/e377faa1a29e9cbb0bc23b6ebdf0368c06d6a10f))
- Improve snort.conf tests ([`0ef9d9d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0ef9d9d47dd323e74b10b4ebf370991aa4df9e9b))
- Remove unused code for retrieving IP address in install.sh ([`7eeaea5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7eeaea524f2e32786a94e86344a45adefe9ea3de))
- Update install script.sh ([`2323e6a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2323e6a7a98ad7ebc416bd337f79954b0e721ecd))
- Update install.sh to call update_ossec_conf_linux in install_snort_linux ([`eb28b52`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/eb28b5266a2609c7496bbc211ead68d1e4dc7bbe))
- Add subprocess import to test_install.py ([`77df65e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/77df65eff37a891dc081f2cf45a7d2fd89e1c68a))
- Update snort.conf tests and fix IP address retrieval ([`5d49b05`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5d49b05b4228b6d2567be623a1a48c27eca1a265))
- Update snort.conf tests and fix IP address retrieval ([`7a00239`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7a002395df22341449df8979ba5f111a8bbcd024))
- Update snort.conf tests and fix IP address retrieval ([`89d5d6e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/89d5d6ea7577e5ae331aac6f730b68cf5275a164))
- Update snort.conf tests and fix IP address retrieval ([`478e444`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/478e444b7ad963a4dec60cd8ead6a2dd32ebc715))
- Update snort.conf tests and fix IP address retrieval ([`de8f999`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/de8f999c6cccb076d09613ee23926b03f5d45eda))
- Update install.sh to support Linux installation ([`6155624`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/615562448dc6c5e3adcb9b79ebb4f961dc3cec1c))
- Update install.sh to support Linux installation ([`7e0a119`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7e0a119acc0bc463259578864c6a321371a993cc))
- Update install.sh to support Linux installation ([`8d603a0`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/8d603a0fd5e6b28809e8e061373c88d00466017a))
- Update install.sh to support Linux installation ([`4558f51`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4558f519ef88837a13ac1bd9b4ecd2e9c0df9d58))
- Update install.sh to support Linux installation and add test coverage ([`16b04a4`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/16b04a4615c7a63db364f7e15c14c8c6af848bf0))
- Update install.sh to support Linux installation and add test coverage ([`222ffcb`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/222ffcbf4ea8139e248ebf2fe15769b7ca613f26))
- Update install.sh to use the main branch URL for installation ([`d186eb6`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/d186eb69ff0c212c0213a561809fe83ee0f750a1))
- Update install.sh to support Linux installation and add test coverage ([`7e04e0d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/7e04e0d10d147db08ddc08b33ed8ea0d247ad944))
- Update snort.ps1 to launch Snort with the default network interface ([`7634544`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/763454478aee30328d06657becb67d329390301f))
- Changed from Out-File -Append to Set-Content for better control over file encoding. ([`476883a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/476883aeee216bb58d9f3ac6cce2a2ca5df638bc))
- Update snort.ps1 to use Invoke-WebRequest for downloading files ([`bac7503`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/bac7503205d4c674a2988eb564d307d0716a0e2a))
- Update snort.ps1 to download files using Invoke-WebRequest and launch Snort with default network interface ([`b491741`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b4917416a52ff8c75bcc5c7dc1a4f15ab4585cbc))
- Update snort.ps1 to use curl.exe for downloading files ([`6ff9630`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6ff963021beeaeab241455ec98eacd4921261ead))
- Update snort.ps1 to use Invoke-WebRequest for downloading files and launch Snort with default network interface ([`cfa7554`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/cfa7554f742c765580b11b3d16d42094de18bd60))
- Update snort.ps1 to use Out-File instead of Set-Content for writing rules to file ([`74ada00`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/74ada0040f8c8bac1fc2b123fded4f413b6a8cd8))
- Update snort.ps1 to use Out-File instead of Set-Content for writing rules to file ([`2804cd0`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/2804cd07dcf23bb764aa46fddba04d4e4a646601))
- Update snort.ps1 to install Snort, Npcap, and WinPcap ([`af13ce6`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/af13ce6db645f35852437e8a0a690f6a80895f1b))
- Update snort.ps1 to remove WinPcap installation ([`eed8335`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/eed8335f9f0392c9db96b5aae3b2fdd4e1c4a056))
- Remove WinPcap installation from Install-Snort function ([`69f3e88`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/69f3e88731d8a092705c8aa6f5be63924a55135f))
- Update snort.ps1 to use UTF-8 encoding when writing rules to file ([`6c7e305`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6c7e305fac73cf42542cefbedcbde6005a6ef7cb))
- Update snort.ps1 to use UTF-8 encoding when writing rules to file ([`a2e2dfd`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a2e2dfdd0eeae461792ea0ca0d5a41ec0b701af4))
- Remove WinPcap installation from Install-Snort function ([`01c4fdf`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/01c4fdf50f2d6b4febdd55e96f95732c600cac22))
- Update snort.ps1 to replace snort.conf file ([`0b2f2fc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/0b2f2fcf765900827ce576e10d297a688719c9f5))
- Update snort.conf output settings ([`22a7f0d`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/22a7f0d5999aff309b942b52509aca225ac6568d))
- Update snort.ps1 to replace snort.conf file ([`a68f555`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a68f55572eba02d10477e97ce9762f9562868ff8))
- Update snort.ps1 to update URLs for local.rules and snort.conf ([`aa14353`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/aa1435363f8e259934ed85a1709e82f216acaf03))
- Remove temporary directory after installation ([`9dcf64e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9dcf64e9c0d87f3996f909f4f22d1495c3f271f8))
- Remove temporary directory after installation ([`91dff1e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/91dff1e3083fc80d974968c2abdbcaf605de39ac))
- Update snort.ps1 to use correct log location ([`1dfaa7b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1dfaa7bd2b3530732959694ad29811d629cf3f41))
- Update readme ([`b9d985f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/b9d985f4903ac689582599c42f828a33462322a0))
- Update snort rules and priorities ([`348cae2`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/348cae23072654868a1295066471dae208667246))
- Update snort.conf and arpspoof configuration ([`c087806`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c087806e1a03ce5726c282137125eb29308f6b1a))
- Update dynamic detection directory in snort.conf ([`608ca71`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/608ca71a247f705b1f792bb2fbe7d7129b39200f))
- Register Snort as a scheduled task to run at startup ([`f26ae18`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f26ae18f48ead1da87d7fd844cd219c19cd666cf))
- Update snort.ps1 to use hidden task settings when registering Snort as a scheduled task ([`3e112b9`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3e112b9013f2f8273c4f4fa57d8390f0d38ec158))
- Update pytest command in pytests.yml to run test_linux.py instead of test_install.py ([`df550e1`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/df550e1fc34ea451a60479645ad717f04e7a057f))
- Add Windows tests for Snort installation and configuration ([`73d34bc`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/73d34bc64a8d7e3f3bcd102ffe405017ae5dd01b))
- Add Windows tests for Snort installation and configuration ([`afb9669`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/afb9669a4186d1c11f758707ee83234e1a06b523))
- Update test_windows.py with string decoding ([`13b228f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/13b228fcf838c26b5529b65a98f1c03c5fe17a79))
- Update test_windows.py to include string decoding for variables ([`9d7804a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/9d7804a6513e245841d0f078221662ca537718a0))
- Update test_windows.py to include string decoding for variables ([`1cd6b41`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1cd6b410243fd53f46740691447bb483af6615c5))
- Update test_windows.py to include string decoding for variables ([`270bf27`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/270bf274bc376c54b020905a73758b8d4016c99a))
- Update test_windows.py to include string decoding for variables ([`64dc8d3`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/64dc8d388013f36ce78c3c40d0c7b4f4b7ca179c))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`4426c74`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4426c7403af9743d3348a01424d3e518c8351e84))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`358f588`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/358f5888ee54a628762db9415d834d3122498471))
- Update pytests.yml to fix path issue for running test_windows.ps1 ([`1befa70`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1befa707af43b26813bc98b4557aa6b1e13e0cf3))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`f6ade2f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/f6ade2f1045b00e01fb1b99f0e3be9b4c188bef6))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`1bdd384`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/1bdd3844a01e144279d5bb576983ae6416642cb6))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`c79c468`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/c79c4685892181882cd9c362c663dc96345ed2a2))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`5f02569`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/5f02569b5e457a2f0f865cf8ef51227733e20a90))
- Update pytests.yml and test_windows.py for Snort installation on Windows ([`a370c2f`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/a370c2f64babb501df4a64a6415cb7df843cf9e1))
- Update Snort test script for Windows ([`3736df5`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/3736df54a4284f44edc9202fe6bdbc53d053c4de))
- Update Snort test script for Windows ([`ad4b83a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/ad4b83a8fa8dadb44647486b9612f97356ada8c3))
- Update Snort test script for Windows ([`59db57b`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/59db57b58b535537b11b365a0827140f21820331))
- Update Snort test script for Windows ([`4a44c75`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/4a44c75a880862440ba460c21640cae307aa1730))
- Update Snort test script for Windows ([`6b7b38a`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/6b7b38a8093882954c053b158de238920f4a7c6f))
- Setup configuration for snort on linux ([`135cbac`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/135cbac8ed62e75b0b51ac40e3acf1356722f93c))
- Change configuration for snort on linux ([`55fa482`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/55fa482c45c714bf59dd586f3663171121692be5))

### Testing

- Use snort in fast mode ([`8898617`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/88986175202e8e6782d8777c83b36b0ce7d44f27))
- Use snort in syslog mode ([`26a5ee8`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/26a5ee8d3f68b8d2123227667775b326db04b3cb))
- Use snort in syslog mode ([`159400e`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/159400e0126d8fd2896360fb558da4f61213ee5a))
- Use snort in full mode ([`46d1bf7`](https://github.com/ADORSYS-GIS/wazuh-snort/commit/46d1bf7bab4ad96f9b558a7485672f526b7a70ad))

<!-- generated by git-cliff -->
