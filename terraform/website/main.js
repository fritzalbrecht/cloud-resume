visitorCount = document.getElementById('visitorCount');

fetch('https://ryse15m27c.execute-api.us-east-1.amazonaws.com/prod/post-visitors', {
    method: 'POST',
})
    .then(() => fetch('https://ryse15m27c.execute-api.us-east-1.amazonaws.com/prod/get-visitors'))
    .then(response => response.json())
    .then(data => {
        visitorCount.innerHTML = JSON.stringify(data);
    })
    .catch(error => {
        visitorCount.innerHTML = 'Error: ' + error;
    });
