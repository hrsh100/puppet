#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../../spec_helper'

require 'puppet/ssl/certificate'

describe Puppet::SSL::Certificate do
    before do
        @class = Puppet::SSL::Certificate
    end

    it "should be extended with the Indirector module" do
        @class.metaclass.should be_include(Puppet::Indirector)
    end

    it "should indirect certificate" do
        @class.indirection.name.should == :certificate
    end

    describe "when managing instances" do
        before do
            @certificate = @class.new("myname")
        end

        it "should have a name attribute" do
            @certificate.name.should == "myname"
        end

        it "should have a content attribute" do
            @certificate.should respond_to(:content)
        end

        it "should be able to read certificates from disk" do
            path = "/my/path"
            File.expects(:read).with(path).returns("my certificate")
            certificate = mock 'certificate'
            OpenSSL::X509::Certificate.expects(:new).with("my certificate").returns(certificate)
            @certificate.read(path).should equal(certificate)
            @certificate.content.should equal(certificate)
        end

        it "should return an empty string when converted to a string with no certificate" do
            @certificate.to_s.should == ""
        end

        it "should convert the certificate to pem format when converted to a string" do
            certificate = mock 'certificate', :to_pem => "pem"
            @certificate.content = certificate
            @certificate.to_s.should == "pem"
        end
    end

    describe "when generating the certificate" do
        it "should fail because certificates must be created by a certificate authority" do
            @instance = @class.new("test")
            lambda { @instance.generate }.should raise_error(Puppet::DevError)
        end
    end
end
