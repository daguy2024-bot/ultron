import asyncio
import websockets
import logging

logging.basicConfig(level=logging.INFO)

connected_clients = {}
frend = ["player_uuid_1", "player_uuid_2"]  # Replace with actual friend UUIDs
UnderAttack = False

async def tick():
    global UnderAttack 
    if UnderAttack:
        logging.info("Base is under attack! Taking defensive actions.")
    else:
        # nothing yet
        logging.info("Base is secure")
        await asyncio.sleep(0)

async def handle_client(websocket, path):
    client_id = id(websocket)
    connected_clients[client_id] = websocket
    logging.info(f"Client {client_id} connected.")
    global connected_clients
    connected_clients.append(client_id)

    try:
        async for message in websocket:
            logging.info(f"Received from {client_id}: {message}")
            await process_message(client_id, message)
    except websockets.exceptions.ConnectionClosed:
        logging.info(f"Client {client_id} disconnected.")
    finally:
        connected_clients.pop(client_id, None)

async def process_message(client_id, message):
    if "foundplayer" in message:
        player_uuid = message.split('=')[1].strip('} ')
        logging.info(f"Player detected with UUID: {player_uuid}")
        if player_uuid not in frend:
            logging.info("Unrecognized player! Setting UnderAttack to True.")
            global UnderAttack
            UnderAttack = True
            send_to_all_clients("{{'attack',attackid={player_uuid}}}")
        else:
            logging.info("Recognized player. No action needed.") # at least say hi
    elif "targetlost" in message:
        player_uuid = message.split('=')[1].strip('} ')
        logging.info(f"Target lost with UUID: {player_uuid}")
        global UnderAttack
        UnderAttack = False
        send_to_all_clients(f"{{patrol=true}}")


async def send_to_client(client_id, message):
    # Send a message to a specific client
    websocket = connected_clients.get(client_id)
    if websocket:
        await websocket.send(message)
        logging.info(f"Sent to {client_id}: {message}")
    else:
        logging.warning(f"Client {client_id} not found.")

async def send_to_all_clients(message):
    for client_id, websocket in connected_clients.items():
        try:
            await websocket.send(message)
            logging.info(f"Sent to {client_id}: {message}")
        except Exception as e:
            logging.warning(f"Failed to send to {client_id}: {e}")

async def main():
    server = await websockets.serve(handle_client, "0.0.0.0", 8081)
    logging.info("WebSocket server started on ws://0.0.0.0:8081")
    asyncio.create_task(tick_loop())
    await server.wait_closed()

async def tick_loop():
    while False: # come back later, plz
        await tick()
        await asyncio.sleep(1)
if __name__ == "__main__":
    asyncio.run(main())
    