#!/bin/bash

#function that takes a dockername as an argument and creates a docker with that name
create_docker() {
	dockername=$1
	echo "Creating $dockername..."
	sudo docker create -i --name $dockername ubuntu > /dev/null
}

#function which takes a dockername as an argument and copies the corresponding files into the docker from the host
copy_files() {
	dockername=$1 
	
	#loop to check dockername and copy the correct files in
	if [ "$dockername" == "docker1" ]; then
		sudo docker cp /home/napier/coursework/DockerFiles1/. docker1:/home/ > /dev/null
		
	elif [ "$dockername" == "docker2" ]; then
		sudo docker cp /home/napier/coursework/DockerFiles2/. docker2:/home/ > /dev/null
	else
		sudo docker cp /home/napier/coursework/DockerFiles3/. docker3:/home/ > /dev/null
	fi
	echo "Loaded files to $dockername..."
}

#function that takes a dockername as a parameter, and sorts the files within depending on the name provided
sort_and_process_files() {
	dockername=$1
	
	#check which name has been provided
	if [ "$dockername" == "docker1" ]; then
	
		#store regular files (lines starting with hyphen, last column) in an array in size ascending (shortest job next)
		files=$(sudo docker exec docker1 ls -r -lS /home/ | grep -E '^-' | awk '{print $9}')
		
		#create a directory with the corresponding name of the docker; enables round robin functionality later on
		sudo docker exec docker1 mkdir /home/docker1
		count=1
		
		#loop through the files in files array and append the count so that they stay sorted in their new directory, then copy to new dir
		for filename in $files; do
			new_filename="$count"_"$filename"
			sudo docker exec docker1 cp /home/$filename /home/docker1/$new_filename
			((count++))
		done
	
	#same as docker1 above, both are shortest job next (size ascending)
	elif [ "$dockername" == "docker2" ]; then
		files=$(sudo docker exec docker2 ls -r -lS /home/ |grep -E '^-' | awk '{print $9}')
		sudo docker exec docker2 mkdir /home/docker2
		counter=1
		for filename in $files; do
			new_filename="$counter"_"$filename"
			sudo docker exec docker2 cp /home/$filename /home/docker2/$new_filename
			((counter++))
		done
	
	#the files are moved in the same way, but the files are unordered as per the spec 
	elif [ "$dockername" == "docker3" ]; then
		files=$(sudo docker exec docker3 ls /home/)
		sudo docker exec docker3 mkdir /home/docker3
		counts=1
		for filename in $files; do
			new_filename="$counts"_"$filename"
			sudo docker exec docker3 cp /home/$filename /home/docker3/$new_filename
			((counts++))
		done
	fi
}

#function to loop through the docker containers in a round robin fashion by quantums of two 
round_robin() {
	
	#infinite loop which is broken when all files arrays are empty
	while true; do
		#loop through dockers
		for dockername in "docker1" "docker2" "docker3"; do
			#store the appropriate files in an array
			files=$(sudo docker exec "$dockername" ls /home/"$dockername"/ 2>/dev/null)
			
			#if array contains something
			if [ -n "$files" ]; then
			
				#process two files at a time, print processing message, write their contents to the final chapter and remove from
				#docker container
				for filename in $(echo "$files" | head -n 2); do
				echo "Processing $filename in $dockername..."
				sudo docker exec "$dockername" cat /home/"$dockername"/"$filename" >> /home/napier/coursework/GAME_OF_DOCKERS.txt
				sudo docker exec "$dockername" rm /home/"$dockername"/"$filename"
				done
			fi
		done
		
		#check if all arrays are empty, if so, break out of the infinite loop. If any array is not empty, keep looping
		empty=true
		for dockername in "docker1" "docker2" "docker3"; do
			files=$(sudo docker exec "$dockername" ls /home/"$dockername"/ 2>/dev/null)
			if [ -n "$files" ]; then
				empty=false
				break
			fi
		done
		
		if [ "$empty" = true ]; then 
			break
		fi
	done
}

#loop through dockers and call the functions 
for dockername in "docker1" "docker2" "docker3"; do
	create_docker "$dockername"
	copy_files "$dockername"
	sudo docker start "$dockername" > /dev/null
	sort_and_process_files "$dockername"
done

echo "Beginning text creation GAME_OF_DOCKERS.txt..."

#call the round robin function seperately; this needs only be called once
round_robin

echo -e "\nCleaning up docker containers..."
#clean up docker containers
sudo docker stop docker1 docker2 docker3 > /dev/null
sudo docker rm docker1 docker2 docker3 > /dev/null

#user interface
#infinite loop, only broken when termination condition is met
while true; do
	echo -e "\nWould you like to: "
	echo "1. Read GAME_OF_DOCKERS.txt"
	echo "2. Remove text from GAME_OF_DOCKERS.txt"
	echo "3. Add text to GAME_OF_DOCKERS.txt"
	echo "4. Terminate the program."
	
	read choice
	
	#case statements to handle user input
	case $choice in
	
	#print contents of file
	1) cat /home/napier/coursework/GAME_OF_DOCKERS.txt ;;
	
	#searches for occurrences of input and replaces with empty string
	2) echo "Enter the text to remove: " && read remove && sed -i "s/$remove//g" /home/napier/coursework/GAME_OF_DOCKERS.txt ;;
	
	#appends text entered to the end of file
	3) echo "Enter the text to add:" && read add && echo "$add" >> /home/napier/coursework/GAME_OF_DOCKERS.txt ;;
	
	#termination condition
	4) echo "Bye!" && exit 0 ;;
	
	#anything other than 1 2 3 4 , do this
	*) echo "Invalid choice; try again." ;;
	esac
done

