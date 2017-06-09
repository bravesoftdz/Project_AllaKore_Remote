	This project initially created by Maickonn Richard and evolved by developers worldwide.
	Any questions, join the community Official AllaKore Remote on Facebook:
	https://www.facebook.com/groups/1202680153082328

	My Github: https://www.github.com/Senjaxus
	

	AllaKore Remote is a Remote Access software open source written in Delphi Seattle.


-----------------------------------------------------------------------


This project is a fork of the original AllaKore Remote. Its purpose is to receive collaborations from all over the world. :D


-----------------------------------------------------------------------


#All components used are native to Delphi itself.

**Now the project is 100% compatible with Delphi Seattle.**
-----------------------------------------------------------


<strong>There are some observations to be taken before opening the project:</strong>

* You should install the native DCLSockets component. Simply open the Delphi XE, click "Component" -> "Install Packages". Now click "Add", now go in the "Bin" folder in the installation of Delphi XE (Example: C:\Program Files (x86)\Embarcadero\Studio\17.0\bin) and open the "dclsocketsXXX.bpl" file. The XXX are numbers according to your version of Delphi.
* The software requires a central server, I recommend host it on a server inside your country, so there is a low latency.
* Like any BETA project, this is subject to bugs that will be corrected over time. I count on the cooperation of all.
* If they can solve any problem, just send the solution that it will be posted.
* The function of the server is to route all data traffic, delivering each packet to the correct user. The server forwards the packets as soon as they are received to gain performance.
* On the Client project, the unit has two Form_Main constant calls "Host" and "Port". In the constant "Host" you must enter the DNS or IP address of your server. In the constant "Port" you should enter the port that was chosen in the constant of the "Server".



<strong>AllaKore Remote has the following functions:</strong>

* Connection ID and Password.
* Remote access with RFB algorithm (Send only what has changed on the screen).
* Data Compression (zLib).
* Sharer files.
* Chat.


