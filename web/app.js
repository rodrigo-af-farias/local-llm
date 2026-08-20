const OLLAMA_URL = "/api/chat";
const MODEL_CONFIG_URL = "/model-config.json";

const messagesElement = document.getElementById("messages");
const promptElement = document.getElementById("prompt");
const sendButton = document.getElementById("sendButton");
const newChatButton = document.getElementById("newChatButton");
const modelNameElement = document.getElementById("modelName");
const modelDisclaimerElement = document.getElementById("modelDisclaimer");

let conversation = [];
let model = null;

async function loadModel() {
  try {
    const response = await fetch(`${MODEL_CONFIG_URL}?t=${Date.now()}`);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();

    if (!data.model) {
      throw new Error("Modelo não configurado.");
    }

    model = data.model;

    modelNameElement.textContent = model;
    modelDisclaimerElement.textContent = `Executando localmente com ${model}`;
  } catch (error) {
    modelNameElement.textContent = "Modelo indisponível";
    modelDisclaimerElement.textContent = `Erro ao carregar modelo: ${error.message}`;
  }
}

function addMessage(role, content) {
  const message = document.createElement("div");

  message.className = `message ${role}`;

  const messageContent = document.createElement("div");

  messageContent.className = "message-content";
  messageContent.textContent = content;

  message.appendChild(messageContent);
  messagesElement.appendChild(message);

  messagesElement.scrollTop = messagesElement.scrollHeight;

  return messageContent;
}

function clearWelcome() {
  const welcome = document.querySelector(".welcome");

  if (welcome) {
    welcome.remove();
  }
}

async function sendMessage() {
  const prompt = promptElement.value.trim();

  if (!prompt || !model) {
    return;
  }

  clearWelcome();

  promptElement.value = "";
  sendButton.disabled = true;

  addMessage("user", prompt);

  conversation.push({
    role: "user",
    content: prompt,
  });

  const assistantElement = addMessage("assistant", "Gerando resposta...");

  try {
    const response = await fetch(OLLAMA_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: model,
        messages: conversation,
        stream: true,
        think: false,
      }),
    });

    if (!response.ok) {
      throw new Error(`ollama retornou HTTP ${response.status}`);
    }

    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    let buffer = "";
    let assistantResponse = "";
    let hasReceivedContent = false;

    while (true) {
      const { value, done } = await reader.read();

      if (done) {
        break;
      }

      buffer += decoder.decode(value, {
        stream: true,
      });

      const lines = buffer.split("\n");

      buffer = lines.pop();

      for (const line of lines) {
        if (!line.trim()) {
          continue;
        }

        const data = JSON.parse(line);

        if (data.message?.content) {
          if (!hasReceivedContent) {
            assistantElement.textContent = "";
            hasReceivedContent = true;
          }

          assistantResponse += data.message.content;

          assistantElement.textContent = assistantResponse;

          messagesElement.scrollTop = messagesElement.scrollHeight;
        }
      }
    }

    if (buffer.trim()) {
      const data = JSON.parse(buffer);

      if (data.message?.content) {
        assistantResponse += data.message.content;
        assistantElement.textContent = assistantResponse;
      }
    }

    conversation.push({
      role: "assistant",
      content: assistantResponse,
    });
  } catch (error) {
    assistantElement.textContent = `Erro ao comunicar com o Ollama: ${error.message}`;
  }

  sendButton.disabled = false;
  promptElement.focus();
}

function newChat() {
  conversation = [];

  messagesElement.innerHTML = `
    <div class="welcome">
      <h1>Como posso ajudar?</h1>
      <p>
        Esta conversa está sendo executada localmente
        através do Ollama.
      </p>
    </div>
  `;

  promptElement.focus();
}

sendButton.addEventListener("click", sendMessage);

newChatButton.addEventListener("click", newChat);

promptElement.addEventListener("keydown", (event) => {
  if (event.key === "Enter" && !event.shiftKey) {
    event.preventDefault();
    sendMessage();
  }
});

loadModel();
