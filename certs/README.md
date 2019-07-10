##### Certificate
* Certivicate chain, certificate body and certificate key in this directory are based on let's encrypt certs.
* AWS ACM uses this let's encrypt cert to import the existing certificate.
* This certifiacte is used by the Application Load Balancer in the HTTPS listener so that if the target in target os based on http protocol and port 80, this certificate will redirect the web request to https.
