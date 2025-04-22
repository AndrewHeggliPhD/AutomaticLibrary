# Library creation with automatic, scheduled updates

### Project description
After my PhD was finished, I was tasked by my previous employer with creating a code script that we referred to as a "library". This script would extract files from an external server, reach into those files to extract the relevant information and create a library of relevant data. 

This was for data in the meat industry, and thus included data such as slaughterhouse number, carcass number and slaughter date. Some individuals that lacked data were included in the document, with cells with no data containing the missing value indicator "NA". An important part of this task was creating a script that could be updated as often as my previous employer wanted, as new data was created almost every day. For more information on how this was achieved, please view the R script within this repository that has descriptions for what each line or segment of code does.   

