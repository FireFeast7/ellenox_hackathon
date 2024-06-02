import os
import google.generativeai as genai
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException

load_dotenv()

GOOGLE_API_KEY = os.getenv('GOOGLE_API_KEY')
os.environ['GOOGLE_API_KEY'] = GOOGLE_API_KEY

genai.configure(api_key=GOOGLE_API_KEY)
summ_model = genai.GenerativeModel('gemini-pro')

app = FastAPI()

@app.get("/home/")
async def home():
    return {"message": "Summarizer is live and working!"}

@app.post('/traffic')
async def traffic(data: dict):
    try:
        speed = data.get('speed')
        speedUncapped = data.get('speedUncapped')
        freeFlow = data.get('freeFlow')
        jamFactor = data.get('jamFactor')
        confidence = data.get('confidence')
        traversability = data.get('traversability')
        
        if None in [speed, speedUncapped, freeFlow, jamFactor, confidence, traversability]:
            raise HTTPException(status_code=400, detail='Missing one or more required parameters')

        user_input = (
            f"speed = {speed} km/h. "
            f"speedUncapped = {speedUncapped} km/h. "
            f"freeFlow = {freeFlow} km/h. "
            f"jamFactor = {jamFactor}. "
            f"confidence = {confidence}. "
            f"traversability = {traversability}."
        )

        chat = summ_model.start_chat(history=[])

        prompt = f"""
            You are my summarizer chatbot who helps me with summarizing travel-related data I have.
            You have to summarize this text: {user_input} into 1 small paragraph.

            Here are details about the metrics used in the text above:
            speed: This parameter represents the current speed of traffic in the area, measured in meters per second (m/s) or kilometers per hour (km/h).

            speedUncapped: Similar to "speed", this parameter also represents the current speed of traffic but without any speed limits applied.

            freeFlow: This parameter represents the expected speed of traffic under ideal conditions or free-flowing conditions. It serves as a reference point for comparing the current traffic speed.

            jamFactor: This parameter indicates the level of congestion or traffic density in the area. It is often represented as a value between 0 and 1, where 0 indicates no congestion (free-flowing traffic) and 1 indicates severe congestion (traffic jam).

            confidence: This parameter indicates the confidence level or reliability of the traffic data provided. It is often represented as a value between 0 and 1, where 1 indicates high confidence in the data accuracy.

            traversability: This parameter describes the overall condition of the road or route in terms of its accessibility or openness. It can have values like "open", "closed", "restricted", etc., indicating whether the road is passable or not.
        """
        response = chat.send_message(prompt)
        summary = response.text

        return {'summary': summary}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post('/weather')
async def weather(data: dict):
    try:
        city = data.get('City')
        temperature = data.get('Temperature')
        feels_like = data.get('Feels Like')
        min_temperature = data.get('Min Temperature')
        max_temperature = data.get('Max Temperature')
        weather = data.get('Weather')
        pressure = data.get('Pressure')
        humidity = data.get('Humidity')
        visibility = data.get('Visibility')
        wind_speed = data.get('Wind Speed')
        wind_degree = data.get('Wind Degree')
        wind_gust = data.get('Wind Gust')
        cloudiness = data.get('Cloudiness')
        sunrise = data.get('Sunrise')
        sunset = data.get('Sunset')
        
        if None in [city, temperature, feels_like, min_temperature, max_temperature, weather, pressure, humidity, visibility, wind_speed, wind_degree, wind_gust, cloudiness, sunrise, sunset]:
            raise HTTPException(status_code=400, detail='Missing one or more required parameters')

        user_input = (
            f"City: {city}, "
            f"Temperature: {temperature}, "
            f"Feels Like: {feels_like}, "
            f"Min Temperature: {min_temperature}, "
            f"Max Temperature: {max_temperature}, "
            f"Weather: {weather}, "
            f"Pressure: {pressure}, "
            f"Humidity: {humidity}, "
            f"Visibility: {visibility}, "
            f"Wind Speed: {wind_speed}, "
            f"Wind Degree: {wind_degree}, "
            f"Wind Gust: {wind_gust}, "
            f"Cloudiness: {cloudiness}, "
            f"Sunrise: {sunrise}, "
            f"Sunset: {sunset}."
        )

        chat = summ_model.start_chat(history=[])

        prompt = f"""
            You are my summarizer chatbot who helps me with summarizing weather-related data I have.
            You have to summarize this text: {user_input} into 1 small paragraph.

            Here are the details about the weather parameters:
            City: The name of the city for which the weather data is provided.

            Temperature: The current temperature in Celsius.

            Feels Like: The "feels like" temperature, which takes into account factors like wind and humidity.

            Min Temperature: The minimum temperature expected for the day.

            Max Temperature: The maximum temperature expected for the day.

            Weather: A description of the current weather conditions.

            Pressure: The atmospheric pressure in hPa (hectopascal).

            Humidity: The relative humidity percentage.

            Visibility: The visibility distance in meters.

            Wind Speed: The speed of the wind in meters per second.

            Wind Degree: The direction of the wind in degrees.

            Wind Gust: The maximum wind gust speed in meters per second.

            Cloudiness: The percentage of cloud cover.

            Sunrise: The time of sunrise.

            Sunset: The time of sunset.
        """
        response = chat.send_message(prompt)
        summary = response.text

        return {'summary': summary}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post('/incidents')
async def incidents(data: dict):
    try:
        incidents_summary = ""
        for incident_id, incident_data in data.items():
            description = incident_data.get('description')
            summary = incident_data.get('summary')
            incident_type = incident_data.get('type')
            criticality = incident_data.get('criticality')
            road_closed = incident_data.get('roadClosed')
            start_time = incident_data.get('startTime')
            end_time = incident_data.get('endTime')

            incidents_summary += f"Incident ID: {incident_id}\n"
            incidents_summary += f"Summary: {summary}\n"
            incidents_summary += f"Description: {description}\n"
            incidents_summary += f"Type: {incident_type}\n"
            incidents_summary += f"Criticality: {criticality}\n"
            incidents_summary += f"Road Closed: {road_closed}\n"
            incidents_summary += f"Start Time: {start_time}\n"
            incidents_summary += f"End Time: {end_time}\n\n"

        chat = summ_model.start_chat(history=[])

        prompt = f"""
            You are my summarizer chatbot who helps me with summarizing incidents in an area.
            You have to summarize the following incidents into 1 small paragraph:

            {incidents_summary}
        """
        response = chat.send_message(prompt)
        summary = response.text

        return {'summary': summary}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
