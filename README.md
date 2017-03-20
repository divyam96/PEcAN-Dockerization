# Solution to the Dockerization problem

This document contains the solution to the dockerization problem where we were to create docker containers for RStudio and PostgreSQL and link them together

## Installation

In order to proceed, it is necessary to have docker installed.  
Docker can be installed easily via curl as it can be seen below:

```
	curl -sSL https://get.docker.com/ | sh

```


## Setting it up

### Preparing The Images

1) Download the Dockerfile from this repository. Run the following command in the directory where the Dockerfile is present in order to build the RStudio-server image.

```
	docker build -t rserver .
```
2) Pull the official PostgreSQL image from the Docker Hub.

```
	docker pull postgres
```
3) Verify the presence of both the images by running the following command

```
	docker images
```

### Running and linking the containers

Now that we have the images ready it's time to spin up the containers.

1) Start the PostgreSQL container named psqlcontainer by running the following command

```
	docker run --name psqlcontainer -e POSTGRES_PASSWORD=docker -P postgres
```
Here by default we have created a user named "postgres" with password "docker".
Now, we will enter the psqlcontainer in order to create a database for testing purposes. 

Open a new instance of the terminal and enter the following command

```
	docker exec -it psqlcontainer /bin/bash 
```
This command enables the user to enter the psqlcontainer via bash.

Now enter the following sequence of commands to create a test database named "testdb" and create a table named "company" within it.

```
su - postgres
       $ createdb testdb
       $ psql testdb

testdb=# CREATE TABLE COMPANY(
   ID INT PRIMARY KEY     NOT NULL,
   NAME           TEXT    NOT NULL,
   AGE            INT     NOT NULL,
   ADDRESS        CHAR(50),
   SALARY         REAL
);

```
2) Now we will create the RStudio-Server container and link it to the psqlcontainer.

```
	docker run -t -i --link psqlcontainer:db -p 8787:8787 rserver /bin/bash 
```
Here db is an alias to the psqlcontainer within the rserver container. 
Once we get the bash prompt we start the RStudio-server by typing the following command within the container. 

```
	rstudio-server start
```
You should now be able to go to the browser and access the RStudio server by typing  http://localhost:8787/

Login with the following 

 username: rstudio
 password: rstudio 

The RStudio GUI should be visible on login. 

3) Establishing a link with the database.

On the RStudio console, Install and load the library "RPostgreSQL" as follows:

```
install.packages("RPostgreSQL")
require("RpostgreSQL")
```
Now go back to the bash prompt and take a look at the environment variables to get the ip and port of the psqlcontainer.

```
env
```
we are concerned with the following two variables in the output:

```
DB_PORT_5432_TCP_ADDR=172.17.0.2
DB_PORT=tcp://172.17.0.2:5432
```
In my case IP=172.17.0.2 and port=5432(standard)

Now go back to the R console and establish the link with "testdb" by typing the following:

```
 pw <- { "docker" }
 drv <- dbDriver("PostgreSQL")
 con <- dbConnect(drv, dbname = "testdb",
                  host = "172.17.0.2", port = 5432,
                  user = "postgres", password = pw)
```

Now verify the link by checking for the existence of the "company" table as can be seen below: 

```
dbExistsTable(con, "company")
[1] TRUE
```
Getting TRUE confirms its existence.


End with an example of getting some data out of the system or using it for a little demo

## Running another test

We will now try creating a table in the psqlcontainer's testdb database via the RStudio console
A table named cartable can be created as follows:

```
sql_command <- "CREATE TABLE cartable
 (
   carname character varying NOT NULL,
   mpg numeric(3,1),
   cyl numeric(1,0),
   disp numeric(4,1),  
   hp numeric(3,0),
   drat numeric(3,2),
   wt numeric(4,3),
   qsec numeric(4,2),
   vs numeric(1,0),
   am numeric(1,0),
   gear numeric(1,0),
   carb numeric(1,0),
   CONSTRAINT cartable_pkey PRIMARY KEY (carname)
 )
 WITH (
   OIDS=FALSE
 );"


 dbGetQuery(con, sql_command)


```
Now, the presence of this new table in the testdb database can be verified from the psqlcontainer as can be seen below :

```
testdb-# \dt
          List of relations
 Schema |   Name   | Type  |  Owner   
--------+----------+-------+----------
 public | cartable | table | postgres
 public | company  | table | postgres
```

## Authors

* **Divyam Malay Shah** -[Divyam](https://github.com/divyam96)

## Acknowledgments

https://www.tutorialspoint.com/postgresql/index.htm
https://www.r-bloggers.com/getting-started-with-postgresql-in-r/


