# Ultron
ComputerCraft: Tweaked police force.

This program uses a python server an androids to monitor areas and attack unwanted visitors.

### Dependancies
* [CC: Androids](https://github.com/ThunderBear2006/CC-Androids)
* [ComputerCraft: Tweaked](https://github.com/cc-tweaked/CC-Tweaked)

### The server:
* Opens a websocket that is configureable
* recieves and sends packets and alerts

### The clients (CC: Androids):
* Connect to the websocket, and watch for unwanted players. attacking them when they are detected.
* return to post when target lost/defeated

## Notices:
This program is early in beta, its going to take some time before getting close to finishing. Also this program is designed as a part of a server I'm in, so this program may support things that aren't publically avalible
The server and client are about to undergo a huge reprogramming, so expect big changes