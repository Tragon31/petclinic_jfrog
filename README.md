# petclinic_jfrog
petclinic exercise for jfrog. Build + test with maven, docker building an image and jf cli push to jfrog artifactory docker repo.

Please note I worked with local jenkins on a Windows computer, this is why you will find "bat" command into Jenkinsfile. 
I add a Jenkinsfile_linux for linux instances, basically just change "bat" with "sh" command.

# exercise_jfrog
# 1) Create a GitHub App with your repository

First I made my repository a GitHub App to have an easier and safer integration between GitHub & Jenkins.
Follow this step by step guide to do so: https://docs.github.com/en/apps/creating-github-apps/registering-a-github-app/registering-a-github-app. 
Do not forget to note GitHub App ID + copy token generated, we will need them for Jenkins configuration.

# 2) JFrog Platform Configuration

For the exercise I created a Free Trial JFrog Platform but you can use yours if already existing. 
To be able to upload your Docker images, you need first to create a docker repository on Artifactory. 
In JFrog Platform, after login, go to "Repositories" -> "Create a Repository", choose "Pre-Built Setup" and select Docker.
Add a name and create.

Go to "Administration" -> "User Management" -> "Access Tokens" and generate a scoped token. Enter description, choose a scope (admin in my case) and assign user name for this token. 
Generate + copy this token, we will need it to configure Jenkins to communicate with JFrog Platform. 

# 3) Configure your jenkins

Go to your jenkins instance, and first install those plugins: (go to "Manage Jenkins" -> "Plugins")
- JFrog Plugin (latest is 1.5.0 for me)
- Docker Pipeline
- GitHub & Git Plugin (should be already installed if you selected jenkins "recommended installation")
- Credentials Plugin (same)
- Maven Integration Plugin

Once installed, you need to setup some configuration in Jenkins. 
Go to "Manage Jenkins" -> "System", find "JFrog Plugin Configuration" section. 
Click "Add JFrog Platform Instance", enter your ServerID (mine testmatjfrog), JFrog Platform URL (mine https://testmatjfrog.jfrog.io) and into "Credentials", create a new "Secret Text" with generated token value (from step 2). Set the ID to "artifactory-access-token" for instance. 
Save your changes.

Go to "Manage Jenkins" -> "Credentials" -> Add Credentials and choose "GitHub App" type (let credentials to global scope).
Fill "App ID" with your GitHub App ID and enter generated token as key (both from our first step).
Fill "ID" with the name of your GitHub App (mine github-app-mat).
Click on create.

Now we will ensure all dependencies are resolved from Maven Central:
We can do it in 2 differents ways: 
a- Creating a global settings.xml into our jenkins and using it for all builds
b- Creating a .m2/settings.xml file into your project and specifying it in command build step into pipeline
I chose a) in this exercise.
Go to "Manage Jenkins" -> "Configuration Files" and click on "Add a new Config". Select Global Maven settings.xml, and add this profile + activeProfile in their respective sections:

  <profiles>

    <profile>
      <id>maven</id>
      <!--Override the repository (and pluginRepository) "central" from the
         Maven Super POM -->
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo1.maven.org/maven2</url>
          <releases>
            <enabled>true</enabled>
          </releases>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>central</id>
          <url>https://repo1.maven.org/maven2</url>
          <releases>
            <enabled>true</enabled>
          </releases>
        </pluginRepository>
      </pluginRepositories>
    </profile>

  </profiles>

  <activeProfiles>
    
    <activeProfile>maven</activeProfile>
    
  </activeProfiles>


Click "submit".
Go to "Manage Jenkins" -> "Tools" and in the section "Maven Configuration"/"Global Defaults Configuration", choose "provided global settings.xml" into the list. 
Select the settings.xml you just created before.

# 4) Configure your job

In jenkins Create a new Item, add a name and choose "pipeline". Click on OK. 

Your job is created. 

Tick "This build has parameters" and add a "Text parameter", name "DOCKER_REG_URL" and value your jfrog artifactory docker url value (mine testmatjfrog.jfrog.io).

Now in "Pipeline" section, choose "Pipeline script from SCM", choose Git as SCM and enter your repository GitHub URL. 

Choose for Credentials the GitHub App credentials we created in our step 3 (Configure your jenkins).
Add the branch you want to build (main here) and you are done for this section.

Save changes, and your pipeline is ready to run!

# 5) Launch your pipeline

Launch your pipeline and you will build your code, test it, build a docker image and then push it into your artifactory !

Finally, to run docker image, just run:

docker pull ghcr.io/tragon31/petclinic_jfrog/appdemo:latest

docker run ghcr.io/tragon31/petclinic_jfrog/appdemo:latest
