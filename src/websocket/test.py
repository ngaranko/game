
import sqlalchemy

from sqlalchemy import create_engine

def get_data():
    engine = create_engine('postgresql+pg8000://dude:dude@localhost/scheduler', echo=True)
    print '123'

if __name__ == '__main__':
    get_data()