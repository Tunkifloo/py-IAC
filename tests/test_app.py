import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_status_endpoint(client):
    response = client.get('/status')
    assert response.status_code == 200
    json_data = response.get_json()
    assert json_data['status'] == 'running'
