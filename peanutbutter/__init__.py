try:
    from .__version__ import version as __version__
    from .__version__ import version_tuple
except ImportError:
    __version__ = "unknown version"
    version_tuple = (0, 0, "unknown version")
