from app.api.v1.endpoints.media import SynthesisRequest


def test_synthesis_request_bounds_text():
    assert SynthesisRequest(text="Hello").text == "Hello"
