# Opdracht voor Claude Code — CloudShirt opdracht 3

Je werkt in de map `opdracht3/` binnen **AWS CloudShell** (Amazon Linux).
Leg alles wat je doet duidelijk uit in het Nederlands. Vraag ALTIJD om
mijn bevestiging voordat je `terraform apply` of `terraform destroy` draait,
want dat maakt echte AWS-resources aan en kost Learner Lab-credits.

## Wat dit project is
Een schoolopdracht. De CloudShirt .NET-webshop wordt op AWS uitgerold met:
- **Terraform** voor de infrastructuur (netwerk, RDS, EFS, EKS-cluster, ECR)
- **AWS EKS** als managed Kubernetes-cluster
- **Ansible** om het cluster te configureren, de app te deployen en logs op te halen

## Mappenstructuur
- `terraform/` : main.tf, variables.tf, 1_fundaments.tf, 2_data_storage.tf,
  3_eks_cluster.tf, outputs.tf, en `docker-build&push.sh`
- `k8s/`       : deployment.yaml, service.yaml, secret.yaml
- `ansible/`   : configure_cluster.yml, collect_logs.yml, destroy_app.yml,
  inventory.ini, requirements.yml, group_vars/all.yml
- `deploy.sh`, `destroy.sh` in de root

## Eisen die het moet halen
- REQ-15: AWS-resources via Terraform
- REQ-16: applicatie gedeployed op AWS via IaC
- REQ-17: app bereikbaar op één extern IP/adres (Service type LoadBalancer)
- REQ-18: docker-images gehost op AWS ECR
- REQ-19: Kubernetes-cluster automatisch uitgerold (EKS)
- REQ-20: cluster met een master die 5 replica's van de website beheert
- REQ-21: Ansible configureert het cluster (past de manifests toe)
- REQ-22: Ansible verzamelt de logfiles van de website

## BELANGRIJKE omgevingsbeperkingen (hou hier rekening mee)
1. **Geen Docker in CloudShell.** Je kunt hier GEEN image bouwen of pushen.
   De stap `docker-build&push.sh` moet op een machine MET Docker gebeuren
   (mijn laptop). Probeer dit niet in CloudShell te forceren.
2. **Region**: gebruik `$AWS_REGION` of `$AWS_DEFAULT_REGION` (in CloudShell
   gezet). `aws configure get region` geeft vaak niets terug.
3. **AWS Academy Learner Lab**: ik mag GEEN eigen IAM-rollen aanmaken; de
   bestaande `LabRole` wordt hergebruikt. Credentials zijn tijdelijk.
4. CloudShell is grotendeels efemeer; alleen `$HOME` blijft bewaard.

## Stap 1 — Controleer en verbeter alle bestanden
Loop alle bestanden na op fouten en consistentie. Let specifiek op:
- `deploy.sh`: de regel die de region bepaalt mag onder `set -e` niet
  stilletjes afbreken. Maak hem robuust (val terug op `$AWS_REGION` /
  `$AWS_DEFAULT_REGION` / `us-east-1`).
- `k8s/deployment.yaml`: de image-regel MOET `image: {{ ecr_url }}:latest`
  zijn (Jinja-variabele), niet `<ECR_URL>`. Ansible rendert dit bestand.
- `terraform/variables.tf`: `cluster_version` moet een actueel ondersteunde
  EKS-versie zijn (bijv. "1.33").
- `terraform/2_data_storage.tf`: de ingress-regel voor poort 1433 vanaf de
  EKS-nodes hoort in de RDS-security group, niet bij EFS.
Vertel per wijziging WAT je verandert en WAAROM. Wijzig niets zonder uitleg.

## Stap 2 — Controleer de benodigde tools
Check of aanwezig/geïnstalleerd: terraform, kubectl, aws CLI, ansible, de
Ansible-collectie `kubernetes.core` en de python-library `kubernetes`.
Installeer ontbrekende onderdelen (gebruik `pip3 install --user ...` en
`ansible-galaxy collection install -r ansible/requirements.yml`).

## Stap 3 — Rol de infrastructuur uit (NA mijn bevestiging)
Draai `terraform init` en `terraform apply` in `terraform/`. Dit duurt
~15-20 min (EKS). Wacht tot het klaar is en toon de outputs.

## Stap 4 — De image (Docker-stap)
Omdat CloudShell geen Docker heeft: controleer of er al een image met tag
`latest` in de ECR-repo `cloudshirt-repo` staat (`aws ecr describe-images`).
- Zo ja: ga door naar stap 5.
- Zo nee: STOP en leg me duidelijk uit dat ik op mijn laptop, vanuit de
  `terraform/` map, `bash 'docker-build&push.sh'` moet draaien, en daarna
  hier verder ga.

## Stap 5 — Deploy de app met Ansible (REQ-21, REQ-17, REQ-20)
Draai vanuit `ansible/`: `ansible-playbook -i inventory.ini configure_cluster.yml`.
Toon daarna de externe URL van de LoadBalancer en controleer met
`kubectl get pods` dat er 5 replica's draaien.

## Stap 6 — Leg het overige uit
Leg uit hoe ik de logs verzamel (`collect_logs.yml`, REQ-22) en hoe ik alles
weer afbreek met `destroy.sh` (eerst de Service/LoadBalancer weg, dan
`terraform destroy`).
