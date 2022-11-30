name: Update Dependabot config

on: push

jobs:
  UpdateDependabot:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Update Dependabot
        shell: pwsh
        run: |
          ./.github/scripts/update-dependabot.ps1 -targetBranch component-updates -outputFile ./.github/dependabot.yml
          
      - name: Push files to repo
        shell: pwsh
        run: |
          # Set the name on the commits as it will appear in Github
          git config --global user.name 'Github dependencies updater'
          git config --global user.email 'alwayson@users.noreply.github.com'
          git add /.github/dependabot.yml 

          $message = git log -1 --pretty=format:"%s"
          if(git status -uno --short) {
            git commit -m "Auto update: $message"
            git push origin
          } 
          else {
            Write-Output "No changes to commit. Bye."
          }

