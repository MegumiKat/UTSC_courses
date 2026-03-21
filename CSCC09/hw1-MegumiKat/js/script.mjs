import { addImage, deleteImage, addComment, deleteComment, getImages, getComments } from './api.mjs';

let currentImageIndex = 0;
let currentPage = 1;  
const commentsPerPage = 10; 


const imageAdding = document.getElementById('imageAdding');
const addImageForm = document.getElementById('addImageForm');
const imageForm = document.getElementById('imageForm');
const currentImageContainer = document.getElementById('currentImageContainer');
const currentImage = document.getElementById('currentImage');
const currentTitle = document.getElementById('currentTitle');
const currentAuthor = document.getElementById('currentAuthor');
const prevImageBtn = document.getElementById('prevImage');
const nextImageBtn = document.getElementById('nextImage');
const deleteImageBtn = document.getElementById('deleteImage');

// Modal elements for comments and adding images
const commentModal = document.getElementById('commentModal');
const modalTitle = document.getElementById('modalImageTitle');
const modalCommentsList = document.getElementById('modalCommentsList');
const modalCommentForm = document.getElementById('modalCommentForm');
const modalCommentAuthor = document.getElementById('modalCommentAuthor');
const modalCommentContent = document.getElementById('modalCommentContent');
const closeModalBtn = document.getElementById('closeModal');
const closeFormBtn = document.getElementById('closeForm');
const submitFormBtn = document.getElementById('submitForm');
const submitCommentBtn = document.getElementById('submitComment');

// Pagination elements
const paginationControls = document.getElementById('paginationControls');
const prevPageBtn = document.getElementById('prevPage');
const nextPageBtn = document.getElementById('nextPage');

// Load the current image index from localStorage (if available)
if (localStorage.getItem('currentImageIndex')) {
    imageDisplay.style.display = 'flex'; 
    currentImageIndex = parseInt(localStorage.getItem('currentImageIndex'), 10);
} else {
    imageDisplay.style.display = 'none'
}


// Toggle the image form
imageAdding.addEventListener('click', () => {
    addImageForm.classList.remove('hidden');
    addImageForm.style.display = 'block';
    // addImageForm.classList.toggle('hidden');
});

// Handle image submission
submitFormBtn.addEventListener('click', (e) => {
    e.preventDefault();
    const title = document.getElementById('imageTitle').value;
    const author = document.getElementById('imageAuthor').value;
    const url = document.getElementById('imageUrl').value.trim();

    if (!title || !author || !url) {
        alert('Please fill in all fields before submitting.'); 
        return; 
    }

    // Add the new image to localStorage
    addImage(title, author, url);

    // Set currentImageIndex to the last image (newly added)
    const images = getImages();
    currentImageIndex = images.length - 1;

    // Save the current image index to localStorage
    localStorage.setItem('currentImageIndex', currentImageIndex);

    // Load the newly added image
    loadImage(currentImageIndex);

    const imageDisplay = document.querySelector('.imageDisplay');
    if (imageDisplay.style.display === 'none') {
        imageDisplay.style.display = 'flex'; 
    }

    // Hide the form
    addImageForm.style.display = 'none';

    // Reset the form
    imageForm.reset();
});

// Load image into the DOM
function loadImage(index) {
    const images = getImages();
    if (images.length === 0) {
        document.querySelector('.imageDisplay').style.display = 'none';
        return;
    }
    document.querySelector('.imageDisplay').style.display = 'flex';
    const image = images[index];
    currentImage.src = image.url;
    currentTitle.textContent = image.title;
    currentAuthor.textContent = `By: ${image.author}`;

    // Save the current image index to localStorage
    localStorage.setItem('currentImageIndex', index);
}

// image deletion
deleteImageBtn.addEventListener('click', () => {
    const images = getImages();
    if (images.length > 1) {
        deleteImage(images[currentImageIndex].imageId);
       if (currentImageIndex > 0) {
            currentImageIndex--;
            console.log("1      " + currentImageIndex);
        }else if(currentImageIndex === 0){
            // currentImageIndex++;
            console.log("2      " + currentImageIndex);
        }
        
    }else if(images.length === 1){
        deleteImage(images[currentImageIndex].imageId);
    }
    loadImage(currentImageIndex);

});

// previous and next image navigation
prevImageBtn.addEventListener('click', () => {
    if (currentImageIndex > 0) {
        currentImageIndex--;
        loadImage(currentImageIndex);
    }else if(currentImageIndex === 0){
        currentImageIndex = getImages().length - 1;
        loadImage(currentImageIndex);
    }
});

nextImageBtn.addEventListener('click', () => {
    const images = getImages();
    if (currentImageIndex < images.length - 1) {
        currentImageIndex++;
        loadImage(currentImageIndex);
    }else if(currentImageIndex === images.length - 1){
        currentImageIndex = 0;
        loadImage(currentImageIndex);
    }
});

// clicking on the image to open the comment modal
currentImage.addEventListener('click', () => {
    openCommentModal(currentImageIndex);
});

// Function to open the comment modal for a specific image
function openCommentModal(index) {
    const images = getImages();
    const image = images[index];

    // image basic information
    modalTitle.textContent = "Image Title:  " + image.title;

    // Reset to the first page of comments
    currentPage = 1;

    // Load comments for the image
    loadCommentsForModal(image.imageId);

    // Show the modal
    commentModal.classList.remove('hidden');
    commentModal.style.display = 'block';
}

// Load comments into the modal with pagination
function loadCommentsForModal(imageId) {
    const comments = getComments(imageId);

    // Sort comments by date (newest first)
    comments.sort((a, b) => new Date(b.date) - new Date(a.date));

    const totalPages = Math.ceil(comments.length / commentsPerPage);
    const start = (currentPage - 1) * commentsPerPage;
    const end = start + commentsPerPage;
    const paginatedComments = comments.slice(start, end);
    let number = 0;

    // Clear the current comment list
    modalCommentsList.innerHTML = '';

    // Display paginated comments
    paginatedComments.forEach(comment => {
        const commentDiv = document.createElement('div');
        number++;
        commentDiv.classList.add('comment');
        commentDiv.innerHTML = `
            <p><strong>${comment.author}</strong> (${new Date(comment.date).toLocaleString()}):</p>
            <p>${comment.content}</p>
            <div class="deleteCommentBtn icon" data-id="${comment.commentId}"></div>
        `;
        modalCommentsList.appendChild(commentDiv);
    });

    // Add event listeners for deleting comments
    document.querySelectorAll('.deleteCommentBtn').forEach(button => {
        button.addEventListener('click', (e) => {
            const commentId = e.target.getAttribute('data-id');
            deleteComment(commentId);
            number--;
            if(number === 0){
                currentPage--;
            }
            loadCommentsForModal(imageId);
        });
    });

    // Update pagination controls
    // paginationControls.style.display = totalPages > 1 ? 'block' : 'none';
    prevPageBtn.disabled = currentPage === 1;
    nextPageBtn.disabled = currentPage === totalPages;
}

// comment submission inside the modal
submitCommentBtn.addEventListener('click', (e) => {
    e.preventDefault();
    const author = modalCommentAuthor.value;
    const content = modalCommentContent.value;
    const images = getImages();

    if (!content || !author) {
        alert('Please fill in all fields before submitting.'); // 提示用户填写所有字段
        return; 
    }

    if (images.length > 0) {
        addComment(images[currentImageIndex].imageId, author, content);
        loadCommentsForModal(images[currentImageIndex].imageId);
        modalCommentForm.reset();
    }
});

//closing the modal
closeModalBtn.addEventListener('click', () => {
    commentModal.style.display = 'none';
});

closeFormBtn.addEventListener('click', () => {
    addImageForm.style.display = 'none';
});

// Handle click outside the modal to close it
window.addEventListener('click', (e) => {
    if (e.target === commentModal) {
        commentModal.style.display = 'none';
    }
});

// pagination controls
prevPageBtn.addEventListener('click', () => {
    if (currentPage > 1) {
        currentPage--;
        const images = getImages();
        loadCommentsForModal(images[currentImageIndex].imageId);
    }
});

nextPageBtn.addEventListener('click', () => {
    const images = getImages();
    const comments = getComments(images[currentImageIndex].imageId);
    const totalPages = Math.ceil(comments.length / commentsPerPage);
    if (currentPage < totalPages) {
        currentPage++;
        loadCommentsForModal(images[currentImageIndex].imageId);
    }
});

// Initial load
loadImage(currentImageIndex);
