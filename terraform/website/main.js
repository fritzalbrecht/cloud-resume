visitorCount = document.getElementById('visitors');

fetch('https://5lojgsv5w4.execute-api.us-east-1.amazonaws.com/prod/post-visitors-tf')
    .then(() => fetch('https://5lojgsv5w4.execute-api.us-east-1.amazonaws.com/prod/get-visitors-tf'))
    .then(response => response.json())
    .then(data => (visitorCount.innerHTML = (data)));
