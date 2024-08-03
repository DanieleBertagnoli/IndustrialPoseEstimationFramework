import socket
import cv2
import pickle
import struct

def client():
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect(('localhost', 9999))

    cap = cv2.VideoCapture(0)

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Send frame to server
        data = pickle.dumps(frame)
        message_size = struct.pack("Q", len(data))
        client_socket.sendall(message_size + data)

        # Receive processed frame from server
        data = b""
        payload_size = struct.calcsize("Q")

        while len(data) < payload_size:
            packet = client_socket.recv(4096)
            if not packet:
                break
            data += packet

        if len(data) < payload_size:
            break

        packed_msg_size = data[:payload_size]
        data = data[payload_size:]
        msg_size = struct.unpack("Q", packed_msg_size)[0]

        while len(data) < msg_size:
            data += client_socket.recv(4096)

        frame_data = data[:msg_size]
        frame = pickle.loads(frame_data)

        cv2.imshow('Processed Frame', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    client_socket.close()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    client()
