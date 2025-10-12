using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Linq;


namespace WinFormsApp2
{


    public partial class Form1 : Form
    {
        private Socket _socket;


        public Form1()
        {

            InitializeComponent();
            _socket = new Socket(
                AddressFamily.InterNetwork,
                SocketType.Stream,
                ProtocolType.Tcp);
        }

        private async void connectBtn_Click(object sender, EventArgs e)
        {
            if (_socket.Connected)
            {
                MessageBox.Show("Вже підключений!");
                return;
            }

            try
            {
                await _socket.ConnectAsync(IPAddress.Loopback, 5000);
                string username = textBox3.Text.Trim();


                if (string.IsNullOrEmpty(username))
                {
                    MessageBox.Show("Будь ласка, введіть ваш юзернейм.", "Помилка введення");
                    _socket.Disconnect(false);
                    return;
                }


                byte[] usernameBytes = Encoding.UTF8.GetBytes($"USER:{username}");
                await _socket.SendAsync(usernameBytes);
                MessageBox.Show("Підключення успішне");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Помилка підключення");
            }

        }

        private async void updataBtn_Click(object sender, EventArgs e)
        {
            if (!_socket.Connected)
            {
                MessageBox.Show("Ти не підключився!");
                return;
            }

            try
            {

                byte[] request = Encoding.UTF8.GetBytes("UPDATE_CHAT");
                await _socket.SendAsync(request);


                byte[] buffer = new byte[4096];
                int recieved = await _socket.ReceiveAsync(buffer);

                if (recieved > 0)
                {
                    string newMessages = Encoding.UTF8.GetString(buffer, 0, recieved);

                    textBox2.Text += Environment.NewLine + "--- Нові повідомлення ---" + Environment.NewLine;
                    textBox2.Text += newMessages;

                    textBox2.SelectionStart = textBox2.Text.Length;
                    textBox2.ScrollToCaret();
                }
                else if (recieved == 0)
                {
                    MessageBox.Show("З'єднання втрачено або сервер закрив з'єднання.");
                }
            }
            catch (SocketException ex) when (ex.SocketErrorCode == SocketError.ConnectionReset || ex.SocketErrorCode == SocketError.TimedOut)
            {
                MessageBox.Show("З'єднання було примусово розірвано або час очікування вийшов.", "Помилка оновлення");
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Помилка при отриманні повідомлень: {ex.Message}", "Помилка");
            }

        }

        private async void sendBtn_Click(object sender, EventArgs e)
        {
            if (!_socket.Connected)
            {
                MessageBox.Show("Ти непідключився");
                return;
            }
            try
            {
                string messageToSend = $"CHAT:{textBox1.Text}";
                byte[] message = Encoding.UTF8.GetBytes(messageToSend);
                await _socket.SendAsync(message);
                textBox1.Clear();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Помилка відправки/прийому: {ex.Message}", "Помилка");

            }
        }
        private async void disconnectBtn_Click(object sender, EventArgs e)
        {
            if (!_socket.Connected)
            {
                MessageBox.Show("Ти і так не підключений!");
            }

            try
            {
                await _socket.DisconnectAsync(true);
                MessageBox.Show("Відключено");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Помилка відключення");
            }

        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }
    }
}
