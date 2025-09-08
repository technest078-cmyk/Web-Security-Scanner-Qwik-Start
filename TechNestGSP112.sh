#!/bin/bash

# ===================== COLOR SCHEME =====================
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
DIM=$(tput dim)
UNDERLINE=$(tput smul)
RESET=$(tput sgr0)

# ===================== UTILITIES =====================
progress_bar() {
  local duration=$1
  local i=0
  while [ $i -le $duration ]; do
    printf "\r${CYAN}${BOLD}[%-*s] %d%%${RESET}" 50 $(printf "#%.0s" $(seq 1 $i)) $((i*2))
    sleep 0.1
    ((i++))
  done
  echo
}

timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

banner() {
echo -e "${MAGENTA}${BOLD}"
cat << "EOF"
████████╗███████╗ ██████╗██╗  ██╗███╗   ██╗███████╗███████╗████████╗
╚══██╔══╝██╔════╝██╔════╝██║  ██║████╗  ██║██╔════╝██╔════╝╚══██╔══╝
   ██║   █████╗  ██║     ███████║██╔██╗ ██║█████╗  ███████╗   ██║   
   ██║   ██╔══╝  ██║     ██╔══██║██║╚██╗██║██╔══╝  ╚════██║   ██║   
   ██║   ███████╗╚██████╗██║  ██║██║ ╚████║███████╗███████║   ██║   
   ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝   ╚═╝   
EOF
echo -e "${RESET}"
}

# ===================== START SCRIPT =====================
clear
banner
echo "${YELLOW}${BOLD}⚡ Starting Lab at $(timestamp) ⚡${RESET}"
echo "${BLUE}Sit back, grab a coffee ☕ — let TechNest handle this.${RESET}"
echo

# Step 1: Authentication
echo "${CYAN}${BOLD}🔑 Step 1: Checking Google Cloud authentication...${RESET}"
gcloud auth list >/dev/null 2>&1 & progress_bar 30
echo "${GREEN}✔ Auth check complete!${RESET}"
echo

# Step 2: Fetch Metadata
echo "${CYAN}${BOLD}🌍 Step 2: Loading Project Metadata...${RESET}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
sleep 1
echo "${GREEN}✔ Zone: $ZONE | Region: $REGION${RESET}"
echo

# Step 3: Download Sample Code
echo "${CYAN}${BOLD}📂 Step 3: Downloading Sample Application...${RESET}"
gsutil -m cp -r gs://spls/gsp067/python-docs-samples . >/dev/null 2>&1 & progress_bar 40
cd python-docs-samples/appengine/standard_python3/hello_world
echo "${GREEN}✔ Sample code ready!${RESET}"
echo

# Step 4: Configuration
echo "${CYAN}${BOLD}⚙️ Step 4: Configuring Application...${RESET}"
sed -i "s/python37/python39/g" app.yaml
cat > requirements.txt <<EOF_REQ
Flask==2.2.5
itsdangerous==2.1.2
Jinja2==3.1.4
werkzeug==2.2.3
EOF_REQ

cat > app.yaml <<EOF_APP
runtime: python39
EOF_APP
sleep 1
echo "${GREEN}✔ Config files generated${RESET}"
echo

# Step 5: Deploy
echo "${CYAN}${BOLD}🚀 Step 5: Deploying to App Engine...${RESET}"
gcloud app create --region=$REGION >/dev/null 2>&1 & progress_bar 25
gcloud app deploy --quiet >/dev/null 2>&1 & progress_bar 50
echo "${GREEN}✔ Deployment successful!${RESET}"
echo

# ===================== END =====================
banner
echo "${MAGENTA}${BOLD}🎉 Lab Completed at $(timestamp)!${RESET}"
echo
echo "${YELLOW}${BOLD}💡 SUBSCRIBE TO TECHNEST for more hacks & labs:${RESET}"
echo "${GREEN}${UNDERLINE}👉 https://www.youtube.com/@TechNest_078${RESET}"
echo

