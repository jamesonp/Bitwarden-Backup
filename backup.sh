#!/usr/bin/env bash

#Environment variables
date=$(date +"%m_%d_%Y")

#Setup commands
mkbitwarden="tar -zvcf /backups/bitwarden/bitwarden_$date.tar.gz /opt/bitwarden/bwdata"
mkrandompass="openssl rand -out /backups/bitwarden/pass.bin 32"
mkbitwardenenc="openssl enc -aes-256-cbc -pass file:/backups/bitwarden/pass.bin -in /backups/bitwarden/bitwarden_$date.tar.gz -out /backups/bitwarden/bitwarden_$date.tar.gz.enc"
mkenckey="openssl rsautl -encrypt -pubin -inkey /backups/scripts/bitwarden.pub -in /backups/bitwarden/pass.bin -out /backups/bitwarden/pass_$date.tar.gz.enc"

#Set location variables
bitwardenbu="/backups/bitwarden/bitwarden_$date.tar.gz"
bitwardenenc="/backups/bitwarden/bitwarden_$date.tar.gz.enc"
bitwardenenckey="/backups/bitwarden/pass_$date.tar.gz.enc"
bitwardenunenckey="/backups/bitwarden/pass.bin"

#Set Gsutil variables
gcsbucket="gs://bitwardenbucket"
gcsbucket="gs://keybucket"
gscp="gsutil cp"

#Execute backups
echo "Making Bitwarden Tar"
$mkbitwarden #create unencrypted tar.gz
echo "Encryping tar"
$mkrandompass
echo "Making random pass.bin" #generate random pass file
$mkbitwardenenc #create encrypted .tar.gz.enc
echo "Encrypting key"
$mkenckey #encrypt the key

#Execute backup sync
$gscp $bitwardenenc $gcsbucket
$gscp $bitwardenenckey $gcsbucketkey

#Cleanup
shred -uz $bitwardenbu && shred -uz $bitwardenenc && shred -uz $bitwardenenckey && shred -uz $bitwardenunenckey

echo "Backup Complete"
