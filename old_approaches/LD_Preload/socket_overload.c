//Derived on code from http://www.goldsborough.me/c/low-level/kernel/2016/08/29/16-48-53-the_-ld_preload-_trick/

#define _GNU_SOURCE

#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <dlfcn.h>
#include <stdio.h>
#include <pwd.h>


int checkWhitelist(const char* path) {
	const int BUF_MAX = 120;
	FILE* wList = fopen("/home/user0/residuefree/LD_Preload/UNIX_whitelist.conf", "r");
	FILE* output = fopen("/home/user0/residuefree/LD_Preload/session_output.text", "a+");
	char buf[BUF_MAX];
	char tmp[BUF_MAX];
	
	
	
	//fprintf(stdout, "%s%c%d", " - ",  path[0], path[0]);
	
	//Check and approve abstract sockets - won't exist outside resFree network namespace
	if(path[0] == 0 && path[1] != 0){
		tmp[0] = '@';
		for(int i = 1; i < BUF_MAX; i++){
			tmp[i] = path[i];
		}
		tmp[BUF_MAX-1] = 0; //ensure null-termination
		fprintf(output, "%s%s\n", tmp, " - whitelist ");
		return 0;
	}

	else{
		strncpy(tmp, path, BUF_MAX);
		fprintf(output, "%s", tmp);
	}


	while (fscanf(wList, "%s", buf) != EOF) {
		if (buf[0] != '#') {
			if (strncmp(buf, tmp, BUF_MAX) == 0) {
				fprintf(output, "%s\n", " - whitelist ");
				return 0;
			}
		}
	}

	fprintf(output, "%s\n", " - blocked");
	return -1;
}

typedef int (*real_socket_t)(int, int, int);
typedef int (*real_connect_t)(int, const struct sockaddr*, socklen_t);

int real_socket(int domain, int type, int protocol){
	return ((real_socket_t)dlsym(RTLD_NEXT, "socket"))(domain, type, protocol);
}

int real_connect(int sockfd, const struct sockaddr *addr, socklen_t addrLen){
	return ((real_connect_t)dlsym(RTLD_NEXT, "connect"))
		(sockfd, addr, addrLen);
}

int socket(int domain, int type, int protocol){
	int fd;
	if(domain == AF_UNIX || domain == AF_LOCAL){
		//fprintf(stdout, "Opening UNIX socket.\n");
	}
	fd = real_socket(domain, type, protocol);
	return fd;
}

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrLen){
	int ret;
	int type;
	//struct sockaddr_un name = sizeof(s
	int length = sizeof(int);
	char* path;

	getsockopt(sockfd, SOL_SOCKET, SO_DOMAIN, &type, &length);
	//fprintf(stdout, "%d\n", type);

	//Filter UNIX socket connections
	if(type == AF_UNIX | type == AF_LOCAL){ 
		//fprintf(stdout, "Connecting to UNIX Socket: ");

		//memset(&name, 0, sizeof(struct sockaddr_un));
		//name = (const struct sockaddr_un *) addr;
		//path = malloc(sizeof(addr->sa_data)+1);
		//strncpy(path, addr->sa_data, sizeof(path));

		//fprintf(stdout, "%s%s", "UNIX Socket: ", addr->sa_data);


		//If socket on whitelist, connect
		if (checkWhitelist(addr->sa_data) == 0) {
			ret = real_connect(sockfd, addr, addrLen);
		}

		//If socket not on whitelist, block connection
		else {
			ret = -1;
		}

		/*PRINT FULL SOCKET PATH (debugging abstract sockets)
		//fprintf(stdout, "%s%d\n", "Addr size: ", sizeof(addr));
		for(int i = 0; i < 32; i++){
			fprintf(stdout, "%c", addr->sa_data[i]);
		}
		fprintf(stdout, "\n");

		for(int i = 0; i < 32; i++){
			fprintf(stdout, "%d%s", addr->sa_data[i], ", ");
		}
		fprintf(stdout, "\n");
		*/
		
		/* SHOW NORMAL UNIX ERRORS (unsuccesful abstract sockets in netns)
		if( (ret = real_connect(sockfd, addr, addrLen)) == -1)
			fprintf(stdout, "%s", "Error connecting.");

		
		fprintf(stdout, "\n");
		*/
		
	}//end UNIX socket block
	//free(path);

	else {
		ret = real_connect(sockfd, addr, addrLen);
	}
	return ret;
}

