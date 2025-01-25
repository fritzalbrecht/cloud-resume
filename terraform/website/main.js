visitorCount = document.getElementById('visitorCount');

fetch('https://api-tf.fritzalbrecht.com/post-visitors', {
    method: 'POST',
})
    .then(() => fetch('https://api-tf.fritzalbrecht.com/get-visitors'))
    .then(response => response.json())
    .then(data => {
        visitorCount.innerHTML = JSON.stringify(data);
    })
    .catch(error => {
        visitorCount.innerHTML = 'Error: ' + error;
    });
