## Overview

This repository contains two FastAPI applications: botapi.py and summarizer.py. These applications utilize Google's Generative AI (genai) to process and summarize various travel-related and weather-related information.

### Prerequisites

- Python 3.8 or higher
- FastAPI
- Uvicorn
- google.generativeai
- requests
- dotenv
- pydantic

### Installation

1. Clone the repository:
    sh
    git clone https://github.com/yourusername/yourrepository.git
    cd yourrepository
    

2. Create and activate a virtual environment:
    sh
    python3 -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    

3. Install the dependencies:
    sh
    pip install -r requirements.txt
    

4. Create a .env file in the root directory and add your API keys:
    sh
    GOOGLE_API_KEY=your_google_api_key
    RAPIDAPI_KEY=your_rapidapi_key
    

### Running the Applications

To run either application, use Uvicorn:

sh
uvicorn botapi:app --reload

or

sh
uvicorn summarizer:app --reload


## botapi.py

This application acts as a travel chatbot. It processes user prompts to identify the type of query (travel inquiry, weather conditions, or general questions) and responds accordingly. 

### Endpoints

- *GET /home/*
  - Returns a message indicating the bot is live.

- *POST /process_prompt/*
  - Processes a user prompt to identify its type and respond.
  - Request body:
    json
    {
        "prompt": "Your user prompt",
        "lat": 0.0,
        "lon": 0.0
    }
    
  - Response:
    json
    {
        "result": [type, response_text, additional_data]
    }
    

- *POST /reset_context/*
  - Resets the chat context for a new conversation.
  - Response:
    json
    {
        "message": "Chat context has been reset."
    }
    

### Utility Functions

- *get_current_location()*: Fetches the current geographical location based on IP address.
- *remove_spaces(text)*: Removes spaces from a given text.
- *get_latlon_from_add(add)*: Fetches latitude and longitude for a given address.
- *get_weather(add, lat, lon)*: Fetches weather data for a given address or coordinates.
- *extract_items(input_string)*: Extracts items from a given input string.
- *mainbot(user_prompt, ulat, ulon)*: Processes the user prompt to determine the type of query and fetches necessary information.

## summarizer.py

This application provides summarization services for traffic, weather, and incident data.

### Endpoints

- *GET /home/*
  - Returns a message indicating the summarizer is live.

- *POST /traffic*
  - Summarizes traffic data.
  - Request body:
    json
    {
        "speed": 50,
        "speedUncapped": 55,
        "freeFlow": 60,
        "jamFactor": 0.5,
        "confidence": 0.8,
        "traversability": "open"
    }
    
  - Response:
    json
    {
        "summary": "Summarized traffic information."
    }
    

- *POST /weather*
  - Summarizes weather data.
  - Request body:
    json
    {
        "City": "City Name",
        "Temperature": 25,
        "Feels Like": 23,
        "Min Temperature": 20,
        "Max Temperature": 30,
        "Weather": "Clear",
        "Pressure": 1013,
        "Humidity": 60,
        "Visibility": 10000,
        "Wind Speed": 5,
        "Wind Degree": 180,
        "Wind Gust": 7,
        "Cloudiness": 10,
        "Sunrise": "06:00",
        "Sunset": "18:00"
    }
    
  - Response:
    json
    {
        "summary": "Summarized weather information."
    }
    

- *POST /incidents*
  - Summarizes incident data.
  - Request body:
    json
    {
        "incident_id_1": {
            "description": "Description of the incident",
            "summary": "Summary of the incident",
            "type": "accident",
            "criticality": "high",
            "roadClosed": false,
            "startTime": "2023-06-01T10:00:00Z",
            "endTime": "2023-06-01T12:00:00Z"
        },
        "incident_id_2": {
            "description": "Description of the second incident",
            "summary": "Summary of the second incident",
            "type": "roadwork",
            "criticality": "medium",
            "roadClosed": true,
            "startTime": "2023-06-01T09:00:00Z",
            "endTime": "2023-06-01T11:00:00Z"
        }
    }
    
  - Response:
    json
    {
        "summary": "Summarized incidents information."
    }
    

### License

This project is licensed under the MIT License - see the LICENSE file for details.

### Acknowledgments

- Google Generative AI for providing the generative model.
- FastAPI for the web framework.
- Uvicorn for the ASGI server.