import logging as l
from abc import ABC, abstractmethod

#Abstract Class for all Pipelines
class Pipeline(ABC):

    def __init__(self):
        self.__dataframe : pandas.DataFrame = NotImplemented #Dataframe
        self.__name : str = NotImplemented #Name of the pipeline
        self.__sourceDate : str = NotImplemented #Date that the data file was created

    @abstractmethod
    def GetDataframe(self): return self.__dataframe

    @property
    def name(self): return self.__name
    
    @property
    def sourceDate(self) : return self.__sourceDate