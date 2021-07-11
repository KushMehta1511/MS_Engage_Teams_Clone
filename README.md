# Microsoft Engage 2021

## Microsoft Teams Clone
This is a Microsoft Teams Clone with features including video call, chat room, file sharing, calendar and authentication. As part of UI developments Dark mode is also provided.

### Framework Used
Flutter and Firebase

### Features Implemented and Details
**Email/Password Authentication:** Used Firebase Authentication and Firebase Firestore to authenticate users upon Login and Signup and store their information.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125186777-ee186c00-e249-11eb-8b79-70d62ceb6ddf.jpg" alt="1625900457072" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125186880-64b56980-e24a-11eb-9046-48b25990e482.jpg" alt="1624700929338" width="200"/>

Validations checks are provided to ensure the user enters a valid email address and minimum length password. It also ensures that already signed up users can’t sign up again and a user who hasn’t signed up can’t login.  
Google sign in: User has the option to sign in using a pre-existing google account as well.


**Profile Page:** Upon login/signup users are directed to their profile page where they can edit their profile photo and username. They can als enter the details of the room in which they want to join. If the room doesn’t exist then a room with the name is created.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187205-143f0b80-e24c-11eb-8194-961025aa3091.jpg" alt="1625990154615" width="200"/>  

Initially the camera icon and the display name text box is disabled. Only after clicking on the edit profile button does it get enabled. The button changes from ”Edit profile” to “update profile”. On the top right we have the calendar icon which leads us to the calendar page. Besides the calendar icon we have the meeting icon which lists down all the meeting rooms in which the user is present.

**Calendar Page:** Monthly calendar view is presented to the user where he/she can add events by selecting the date and start time and end time. Syncfusion Calendar Flutter package was used to develop the calendar. After creating an event the user can view the event by long pressing the date in the calendar view. A colored dot appears below the date to let the user know that an event has been set. The events are stored for future reference.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187255-46e90400-e24c-11eb-83d9-38b298fa2476.jpg" alt="1625990154609" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187278-641dd280-e24c-11eb-85eb-f4a02607ee29.jpg" alt="1625990154603" width="200"/>  
                     
                         
The below two images are after the event has been created. The above two images are before the event has been created and the event creation page.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187294-857ebe80-e24c-11eb-82e6-c2b31f692033.jpg" alt="1625990154596" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187304-94657100-e24c-11eb-8ec7-0a12a6d6cf80.jpg" alt="1625990154589" width="200"/>  

**User Dashboard:** This page lists down all the rooms in which the user is present. Upon tapping on the particular meeting the user is redirected to the chat room of the meeting.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187381-01790680-e24d-11eb-8ad5-4e4f3ad8987b.jpg" alt="1625289141945" width="200"/>  

Through the floating icon button we can enter a new meeting.

**Chatting Facility in the rooms:** Once the user enters the room he/she can chat with the fellow members present in the room. The chat message shows the username to distinguish between the messages. On the top right corner the logout button is placed which logs out the user from the current account and sends back to the login page. Beside it we have the video calling icon which enables the user to make a video call.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187617-16a26500-e24e-11eb-9d6e-579e6a72e725.jpg" alt="1625289141963" width="200"/>



Beside the video call icon we have the file sharing option by which we can share files, images, etc with the people of the meeting. 

**Video Calling Feature:** The user is asked to input the subject of the video meet and also the name which he wishes to showcase the other participants. The email address and room details are automatically displayed.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187878-5f0e5280-e24f-11eb-8e24-0c936d9a4bdf.jpg" alt="1625990154583" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187950-a268c100-e24f-11eb-8b9a-f499b06d0c41.jpg" alt="Video Call Page" width="200"/>  
                        

The video calling feature is powered by Jitsi Meet. Once the user joins the meeting the above shown screen appears with several options available. Some standard features like Muting/Unmuting, Turning on/off video, chatting within video call, switching the camera and exiting. Several other features which enhance the video calling experience have been enabled as displayed below.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125187960-c4624380-e24f-11eb-840d-30f1383e272f.jpg" alt="Video Call Features" width="200"/>  

To share the meeting link with your friends, click on the “Invite Someone” icon and share the link with the desired person.

**Internal Mailing, Calling and messaging feature:** From within a chat room the user can choose to either mail, make a phone call or send an SMS by entering the required details. For instance if a user wants to send an email then after entering the required email address he/she would be redirected to gmail or any other application in the mobile. Clicking on the menupopup of the chat room we get the options to select from. Upon selecting an option an alert dialog box opens where we can enter the necessary details.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188013-025f6780-e250-11eb-9298-38c6ba787612.jpg" alt="1625990154576" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188030-1905be80-e250-11eb-939a-492d6e8f5657.jpg" alt="1625990154569" width="200"/>  
             

**File Sharing:** The application allows sharing of files and images within a particular meeting room for the other members. Clicking on the file icon on the top of the chat page leads us to the file sharing page. The floating action button in the bottom right corner allows us to upload new files from the phone storage.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188071-33d83300-e250-11eb-8c0e-402b52d23638.jpg" alt="1625289141957" width="200"/>  


**Dark Mode:** The app recognises the system’s theme and changes accordingly. If the default theme of the system is dark then the app opens up in dark mode otherwise in light mode. The images shown above are of the light mode. The images below are for the dark mode.  
  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188143-58cca600-e250-11eb-8673-19e84d45b522.jpg" alt="1624700929333" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188172-73068400-e250-11eb-8ed1-a81447f3434d.jpg" alt="1625990154563" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188188-831e6380-e250-11eb-9371-cbb37e036d6e.jpg" alt="1625990154557" width="200"/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="https://user-images.githubusercontent.com/65716045/125188206-95000680-e250-11eb-9084-c534164ecd26.jpg" alt="1625990154550" width="200"/>  

## APK of the app
The latest release of the application is published [here](https://github.com/KushMehta1511/MS_Engage_Teams_Clone/releases/tag/v8.7.21).
                   

                    
