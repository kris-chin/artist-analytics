import pandas
import logging as l
from abc import ABC, abstractmethod

#Abstract Method for all Pipelines
class Pipeline(ABC):

    @abstractmethod
    def __init__(self):
        self.__dataframe : pandas.DataFrame = NotImplemented

    @abstractmethod
    def GetDataframe(self):
        return self.__dataframe