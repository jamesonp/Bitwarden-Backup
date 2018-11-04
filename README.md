# Bitwarden-Backup

I just wanted to share how I backup my self hosted Bitwarden server on Ubuntu 18.04.

Prerequisites:

1) Have a Google Cloud Platform Account (GCP)

2) Create two Storage buckets -  one for the encrypted backups and one for the encrypt keys.  I recommend making these coldline buckets with a retention policy of 90 days for cost purposes.

3) Install [Cloud SDK/gsutil](https://cloud.google.com/storage/docs/gsutil_install#deb) and do "gcloud init" to give your install access to your GCP account.

4) Create a directory on your server to temp store backups prior to upload to GCP.  I use /backups/bitwarden.  I store my scripts in /backups/scripts.

5) Generate a private key:

    openssl genrsa -out /backups/scripts/bitwarden.pem 2048    

6) Generate a public key from your private key:

    openssl rsa -in /backups/scripts/bitwarden.pem -out /backups/scripts/bitwarden.pub -outform PEM -pubout

7) Save your private key somewhere safe and delete/shred it on your Bitwarden server.  If you lose this you will not be able to decrypt your backups.

Save the script as filename.sh somewhere and chmod +X it.

I set this up to run nightly with a cron job:

    0 0 * * * /location/of/script/./filename.sh > /backups/scripts/logs/log.txt    

To un-encrypt your backup you'd just do something similar to:

    openssl rsautl -decrypt -inkey /path/to/private/key.pem -in /path/to/encrypted/backup/pass_04_27_2018.tar.gz.enc -out pass.bin #decrypt your key
    openssl enc -aes-256-cbc -d -pass file:/path/to/decrypted/pass.bin -in /path/to/encrypted/bitwarden_04_27_2018.tar.gz.enc -out bitwarden.tar.gz #decrypt your backup

To restore your backup you would stop the Bitwarden service, restore the entire bwdata folder from backup then restart the Bitwarden service.

I plan on cleaning up this script eventually but this works great for now.  I've restored twice using this backup method.
