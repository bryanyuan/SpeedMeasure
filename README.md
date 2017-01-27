# SpeedMeasure

**Speed Measure Tool** on **iOS** platform.

Adopt *NSURLSessionDataTask* and *NSURLSessionDownloadTask* to perform the actually download job.

Firstly, the task was *NSURLSessionDataTask*, it prompt us if it received the first response, we'll treat it as the timestamp that download jobs actually happen. 

then switch the task to *NSURLSessionDownloadTask*, it updates the progress periodically and enable us to calculate the download rate.
