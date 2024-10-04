import pyttsx3
import speech_recognition as sr
import datetime
import wikipedia
import webbrowser
import os
import comtypes.client

engine = pyttsx3.init('sapi5')
voices = engine.getProperty('voices')
engine.setProperty('voice', voices[0].id)

def speak(audio):
    engine.say(audio)
    engine.runAndWait()

def wishme():
    hour = int(datetime.datetime.now().hour)
    if hour >= 5 and hour < 12:
        speak("good morning!")
    
    elif hour >= 12 and hour < 17:
        speak("good afternoon!")
    
    elif hour >= 17 and hour < 20:
        speak("good evening!")
    else:
        speak("good night!")

    speak("i am jarvis , please tell me how may i help you")

def takecommand():
    # now jarvis take our input in your voices

    r = sr.Recognizer()
    with sr.Microphone() as source:
        print("listening...")
        r.pause_threshold = 1
        audio = r.listen(source)

    try:
        print("recognizing. . .")
        query = r.recognize_google_cloud(audio, language= 'en-in')
        print(f"user said: {query}\n")

    except Exception as e:
        print("say that again please.....")
        return "none"
    return query

if __name__ == "__main__":
    wishme()
    while True:
        query = takecommand().lower()

        if 'wikipedia' in query:
            speak('searching wikipedia...')
            query = query.replace("wikipedia", "")
            results = wikipedia.summary(query,sentences=2)
            speak("According to wikipedia")
            print (results)
            speak(results)

        elif 'open youtube' in query:
            webbrowser.open("youtube.com")

        elif 'open google' in query:
            webbrowser.open("google.com")

        elif 'open stackoverflow' in query:
            webbrowser.open("stackoverflow.com")

        elif 'play music' in query:
            music_dir = 'D:\\songs\\favorite'
            songs = os.listdir(music_dir)
            print(songs)
            os.startfile(os.path.join(music_dir, songs[0]))

        elif 'the time' in query:
            strtime = datetime.datetime.now().strftime("%H:%M:%S")
            speak(f"sir, the time is {strtime}")


    