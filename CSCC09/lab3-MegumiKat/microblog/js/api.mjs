/*  ******* Data types *******
    message objects must have at least the following attributes:
        - (String) messageId
        - (String) author
        - (String) content
        - (Int) upvote
        - (Int) downvote
****************************** */

// retrieve all messages
export function getMessages() {
    const messages = JSON.parse(localStorage.getItem("messages")) || [];
    return messages;
}

// add a message
export function addMessage(author, content) {
    const messages = getMessages();
    const messageId = Date.now().toString();
    const newMessage = {
        messageId,
        author,   
        content,
        upvotes: 0,
        downvotes: 0
    };
    messages.push(newMessage);
    localStorage.setItem("messages", JSON.stringify(messages));
    return newMessage;
}

// delete a message given its messageId
export function deleteMessage(messageId) {
    let messages = getMessages();
    messages = messages.filter(msg => msg.messageId !== messageId);
    localStorage.setItem("messages", JSON.stringify(messages));
}