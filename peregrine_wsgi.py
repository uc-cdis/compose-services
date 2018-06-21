from peregrine.api import app_init
from peregrine.api import app

app.config.from_object('peregrine.dev_settings')
app_init(app)
app.debug = True
application = app