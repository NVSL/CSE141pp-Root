from setuptools import setup, find_packages

setup(
    name="CSE142LBoot",
    version="0.1",
    install_requires = [
        "click==8",
     ],
    packages=find_packages('src'),
    package_dir={'': 'src'},
    entry_points={
        'console_scripts' :[
            'show_boot=CSE142LBoot.show_boot:main'
        ]}
)
