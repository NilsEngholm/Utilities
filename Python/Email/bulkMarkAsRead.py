import os.path
import datetime

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.modify"]  # Changed scope to allow modification

# Function to authenticate Gmail API | pasted this DIRECT from google API quickstart lol
def authenticateGmail():
    """Authenticate the user and return the Gmail API service."""
    creds = None
    token_path = "Secret/Gmail Secret/token.json"  # Use forward slashes for file paths
    client_secret_path = "Secret/Gmail Secret/credentials.json"  # Correct file for client secret

    # Check if we have saved credentials
    if os.path.exists(token_path):
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)

    # If no valid credentials available, let the user log in
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(client_secret_path, SCOPES)
            creds = flow.run_local_server(port=0)

        # Save the credentials for future use
        with open(token_path, "w") as token:
            token.write(creds.to_json())

    # Return the authenticated service
    return build("gmail", "v1", credentials=creds)

# get dates
def aMonthAgo():
    today = datetime.date.today()
    oneMonthAgo = today - datetime.timedelta(days=30)
    return oneMonthAgo.strftime('%Y/%m/%d')

# mark as read fn
def markAllAsRead():
    """Mark unread emails over 30 days old as read, handle pagination for large volumes."""
    try:
        service = authenticateGmail()  # user auth
        oneMonthOld = aMonthAgo()  # get date - 30days

        # get unread emails > 30days old
        query = f"is:unread before:{oneMonthOld}"
        totalMarked = 0
        nextPageToken = None

        while True:
            # made a while loop because the default is 100 emails
            # while there are unread emails continue the loop
            results = service.users().messages().list(userId='me', q=query, pageToken=nextPageToken).execute()
            messages = results.get('messages', [])

            # if there are no unread messages just break
            if not messages:
                print('No more unread messages older than 30 days found.')
                break

            # mark as read
            for message in messages:
                service.users().messages().modify(
                    userId='me',
                    id=message['id'],
                    body={'removeLabelIds': ['UNREAD']}
                ).execute()
            
            # count emails marked
            totalMarked += len(messages)
            print(f"Marked {totalMarked} emails as read so far.")

            # go to next page
            nextPageToken = results.get('nextPageToken')

            # if no more pages stop the loop
            if not nextPageToken:
                break

        print(f"Total {totalMarked} emails marked as read.")

    except HttpError as error:
        print(f"An error occurred: {error}")
    except Exception as e:
        print(f"Unexpected error occurred: {e}")

if __name__ == "__main__":
    markAllAsRead()