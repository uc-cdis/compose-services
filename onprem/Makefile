
all: fence s3indexer

# build and tag an instance of fence
fence:
	git clone https://github.com/ohsu-comp-bio/fence.git
	cd fence ;\
		git checkout onprem ; \
		docker build --network=host -t onprem/fence .

# build and tag an instance of indexs3client
indexs3client:
	git clone https://github.com/ohsu-comp-bio/indexs3client.git
	cd indexs3client ;\
		git checkout onprem ; \
		docker build --network=host -t onprem/indexs3client .

# build and tag an instance of s3indexer
s3indexer: indexs3client
	git clone https://github.com/ohsu-comp-bio/gen3-s3indexer.git
	cd gen3-s3indexer ;\
		git checkout onprem ; \
		docker build --network=host -t onprem/s3indexer .
