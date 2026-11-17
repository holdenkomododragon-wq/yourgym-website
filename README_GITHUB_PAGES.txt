YOURGYM.US — FREE WEBSITE PUBLISHING
====================================

This package contains the YourGym.us static website and the current Windows app download (YourGym 1.8.25.9).
It is prepared for GitHub Pages with a custom domain. GitHub Pages hosting is free for a public repository; your Porkbun domain registration/renewal remains separate.

FILES
-----
index.html                         Main website
styles.css                         Responsive styling
assets/favicon.svg                 Website icon
YourGymDesktop_1.8.25.9.exe        Windows x64 app download
CNAME                              yourgym.us custom domain marker
.nojekyll                          Disable Jekyll processing
robots.txt / sitemap.xml           Search-engine files
PUBLISH_TO_GITHUB.ps1              Automated repository setup/push
CHECK_DNS.ps1                      Check DNS after Porkbun changes

QUICK START (WINDOWS)
---------------------
1. Extract this ZIP into a folder, for example:
   C:\Users\YOUR_WINDOWS_USER\Documents\YourGym_US_Website

2. Install Git and GitHub CLI if missing. In PowerShell:
   winget install --id Git.Git -e
   winget install --id GitHub.cli -e
   Close and reopen PowerShell after installation.

3. Sign in to GitHub from PowerShell:
   gh auth login
   Choose GitHub.com, HTTPS, and sign in through your browser.

4. Open PowerShell in the extracted website folder and run:
   Set-ExecutionPolicy -Scope Process Bypass
   .\PUBLISH_TO_GITHUB.ps1

   The script creates a PUBLIC repository named `yourgym-website` under your GitHub account and pushes this website. Public visibility is required for free GitHub Pages hosting. The Windows EXE will be publicly downloadable from your site.

5. In the browser tab opened by the script, go to Settings > Pages.
   Under Build and deployment choose:
     Source: Deploy from a branch
     Branch: main
     Folder: /(root)
   Save if Pages is not already configured.
   Under Custom domain enter:
     yourgym.us
   Click Save.
   The repository already includes the CNAME file.

6. Configure Porkbun DNS only AFTER adding yourgym.us in GitHub Pages.
   Porkbun > Domain Management > yourgym.us > DNS.
   Add these four A records (Host is @ or blank):
     185.199.108.153
     185.199.109.153
     185.199.110.153
     185.199.111.153

   Add one CNAME record:
     Host: www
     Answer: YOUR-GITHUB-USERNAME.github.io
   Replace YOUR-GITHUB-USERNAME with your actual GitHub username. Do not include /yourgym-website.

   Before adding records, remove only conflicting website records for @ or www that point to a different web host (old A/AAAA/ALIAS/ANAME at @, or CNAME/A/AAAA at www). Do NOT delete MX or TXT records; these may be used for email or domain verification. Do NOT change nameservers.

7. Wait for DNS to update, then run:
   .\CHECK_DNS.ps1
   GitHub Pages DNS updates can take up to 24 hours. When GitHub Pages shows the domain check is successful, turn on Enforce HTTPS in Settings > Pages. The certificate option may take additional time to appear.

OPTIONAL MANUAL CHECKS
----------------------
   Resolve-DnsName yourgym.us -Type A
   Resolve-DnsName www.yourgym.us -Type CNAME
   Invoke-WebRequest https://yourgym.us -UseBasicParsing

UPDATE THE WEBSITE LATER
------------------------
Replace the EXE in this folder with the next release, update the version text/link in index.html, then run PUBLISH_TO_GITHUB.ps1 again. It stages, commits, and pushes website updates.

IMPORTANT
---------
- This is a STATIC website only. GitHub Pages does not host the YourGym database or authentication backend; those remain on Supabase.
- The site's EXE link is a public download. Anyone visiting your domain can download the Windows app.
- The app's first launch requires an internet connection to download and verify its desktop runtime.
- The current EXE is for 64-bit Windows, not iPhone or Android.
- Do not upload Supabase Secret/service-role keys to GitHub. None are needed in this site package.
