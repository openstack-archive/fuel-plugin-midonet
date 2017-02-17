Mirantis Fuel MidoNet plugin
============================

Compatible versions:

- Mirantis Fuel 9.0 , Fuel 9.1 and Fuel 9.2
- MidoNet v5.2 / v5.4
- Midokura Enterprise MidoNet 5.2 & 5.4

How to build the plugin
-----------------------

- Install Fuel plugin builder (fpb)

  ::

   # pip install fuel-plugin-builder

- Clone the plugin repo and run fpb there:

  ::

   $ git clone https://github.com/openstack/fuel-plugin-midonet
   $ cd fuel-plugin-midonet
   $ fpb --build .

A *rpm* called `midonet-9.2-9.2.0-1.noarch.rpm` should be created in
the same directory.

Follow the documentation to install and configure the plugin. You can read the
`rst` files in this very repository, or you can build a documentation file.

How to build the documentation
------------------------------

You need to have **Sphinx** installed in your computer. Hint; for full Latex
Sphinx support on Ubuntu one needs **python-sphinx**, **rst2pdf**, **texlive**
and **texlive-latex-extra** packages. The Makefile provides several target
formats to do so. Go to the `doc` directory and run:

    make latexpdf

or:

    make html

or:

    make pdf

You will need `rst2pdf` to run the last one.
