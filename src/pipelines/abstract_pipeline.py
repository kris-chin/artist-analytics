import pandas
import logging as l
from abc import ABC, abstractmethod

#Abstract Method for all Pipelines
class Pipeline(ABC):

    @abstractmethod
    def __init__(self):
        self.__dataframe : pandas.DataFrame = NotImplemented
        self.__name : str = NotImplemented

    @abstractmethod
    def GetDataframe(self):
        return self.__dataframe

    @property
    def name(self):
        return self.__name