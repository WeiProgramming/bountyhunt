import urllib

def string_encode(str):
	return urllib.parse.quote(str)
	
if __name__=="__main__":
	payload = "string here"
# Example
	encoded_payload = string_encode(payload)
