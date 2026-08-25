/*  ******* Data types *******
    image objects must have at least the following attributes:
        - (String) imageId 
        - (String) title
        - (String) author
        - (String) url
        - (Date) date

    comment objects must have the following attributes
        - (String) commentId
        - (String) imageId
        - (String) author
        - (String) content
        - (Date) date

****************************** */

// Generate a unique id for images and comments
function generateId() {
    return '_' + Math.random().toString(36).slice(2, 11);
}

// Get all images from localStorage
export function getImages() {
    return JSON.parse(localStorage.getItem('images')) || [];
}


// Get all comments for a specific image
export function getComments(imageId) {
    const comments = JSON.parse(localStorage.getItem('comments')) || [];
    return comments.filter(comment => comment.imageId === imageId);
}


// Add an image to the gallery
export function addImage(title, author, url) {
    const images = JSON.parse(localStorage.getItem('images')) || [];
    const newImage = {
        imageId: generateId(),
        title,
        author,
        url,
        date: new Date()
    };
    images.push(newImage);
    localStorage.setItem('images', JSON.stringify(images));
    return newImage;
}

// Delete an image from the gallery
export function deleteImage(imageId) {
    let images = JSON.parse(localStorage.getItem('images')) || [];
    images = images.filter(image => image.imageId !== imageId);
    localStorage.setItem('images', JSON.stringify(images));
}


// Add a comment to an image
export function addComment(imageId, author, content) {
    const comments = JSON.parse(localStorage.getItem('comments')) || [];
    const newComment = {
        commentId: generateId(),
        imageId,
        author,
        content,
        date: new Date()
    };
    comments.push(newComment);
    localStorage.setItem('comments', JSON.stringify(comments));
    return newComment;
}

// Delete a comment from an image
export function deleteComment(commentId) {
    let comments = JSON.parse(localStorage.getItem('comments')) || [];
    comments = comments.filter(comment => comment.commentId !== commentId);
    localStorage.setItem('comments', JSON.stringify(comments));
}